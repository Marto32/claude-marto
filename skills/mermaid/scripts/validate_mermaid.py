#!/usr/bin/env python3
"""
Mermaid Diagram Syntax Validator

Validates Mermaid diagram syntax using the official mermaid-cli (mmdc).
Returns structured validation results.

Usage:
    validate_mermaid.py <diagram.mmd>
    echo "graph TD; A-->B" | validate_mermaid.py --stdin

Exit codes:
    0 - Valid syntax
    1 - Invalid syntax
    2 - Tool not available
"""

import subprocess
import sys
import json
import tempfile
from pathlib import Path


def detect_diagram_type(content: str) -> str:
    """Detect diagram type from content"""
    first_line = content.strip().split('\n')[0].lower() if content.strip() else ''

    type_map = {
        'graph': 'flowchart',
        'flowchart': 'flowchart',
        'sequencediagram': 'sequence',
        'classdiagram': 'class',
        'statediagram': 'state',
        'erdiagram': 'er',
        'gantt': 'gantt',
        'gitgraph': 'git-graph',
        'journey': 'user-journey',
        'pie': 'pie',
        'mindmap': 'mindmap',
        'timeline': 'timeline',
        'quadrantchart': 'quadrant'
    }

    for keyword, diagram_type in type_map.items():
        if keyword in first_line.replace(' ', '').replace('-', ''):
            return diagram_type

    return 'unknown'


def parse_mmdc_errors(stderr: str) -> list:
    """Parse error messages from mmdc stderr output"""
    errors = []
    for line in stderr.split('\n'):
        line_lower = line.lower()
        if any(keyword in line_lower for keyword in ['error', 'parse', 'syntax', 'invalid', 'unexpected']):
            clean_error = line.strip()
            if clean_error and not clean_error.startswith('('):
                errors.append(clean_error)

    return errors if errors else ['Syntax error in diagram']


def validate_diagram(content: str) -> dict:
    """
    Validate Mermaid diagram syntax

    Returns:
        {
            'valid': bool,
            'errors': list[str],
            'warnings': list[str],
            'diagram_type': str
        }
    """
    if not content or not content.strip():
        return {
            'valid': False,
            'errors': ['Empty diagram content'],
            'warnings': [],
            'diagram_type': 'unknown'
        }

    # Create temp files for validation
    temp_input = None
    temp_output = None

    try:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.mmd', delete=False) as f:
            f.write(content)
            temp_input = f.name

        with tempfile.NamedTemporaryFile(suffix='.svg', delete=False) as f:
            temp_output = f.name

        # Call mmdc via npx (no installation needed)
        result = subprocess.run(
            ['npx', '-y', '@mermaid-js/mermaid-cli@latest',
             '-i', temp_input, '-o', temp_output],
            capture_output=True,
            text=True,
            timeout=10
        )

        # Parse results
        validation = {
            'valid': result.returncode == 0,
            'errors': [],
            'warnings': [],
            'diagram_type': detect_diagram_type(content)
        }

        if result.returncode != 0:
            # Parse error messages from stderr
            validation['errors'] = parse_mmdc_errors(result.stderr)

        return validation

    except subprocess.TimeoutExpired:
        return {
            'valid': False,
            'errors': ['Validation timeout (diagram too complex or infinite loop)'],
            'warnings': [],
            'diagram_type': detect_diagram_type(content)
        }
    except FileNotFoundError:
        return {
            'valid': False,
            'errors': ['mermaid-cli not available - npx command not found'],
            'warnings': [],
            'diagram_type': detect_diagram_type(content)
        }
    except Exception as e:
        return {
            'valid': False,
            'errors': [f'Validation error: {str(e)}'],
            'warnings': [],
            'diagram_type': detect_diagram_type(content)
        }
    finally:
        # Cleanup temp files
        if temp_input:
            Path(temp_input).unlink(missing_ok=True)
        if temp_output:
            Path(temp_output).unlink(missing_ok=True)


def main():
    """Main entry point"""
    # Parse arguments
    if len(sys.argv) > 1 and sys.argv[1] == '--stdin':
        content = sys.stdin.read()
    elif len(sys.argv) > 1:
        file_path = sys.argv[1]
        try:
            with open(file_path, 'r') as f:
                content = f.read()
        except FileNotFoundError:
            print(json.dumps({
                'valid': False,
                'errors': [f'File not found: {file_path}'],
                'warnings': [],
                'diagram_type': 'unknown'
            }), file=sys.stderr)
            sys.exit(2)
        except Exception as e:
            print(json.dumps({
                'valid': False,
                'errors': [f'Error reading file: {str(e)}'],
                'warnings': [],
                'diagram_type': 'unknown'
            }), file=sys.stderr)
            sys.exit(2)
    else:
        print("Usage: validate_mermaid.py <diagram.mmd>", file=sys.stderr)
        print("       echo 'graph TD; A-->B' | validate_mermaid.py --stdin", file=sys.stderr)
        sys.exit(2)

    # Validate diagram
    result = validate_diagram(content)

    # Output result as JSON
    print(json.dumps(result, indent=2))

    # Exit with appropriate code
    if not result['valid']:
        sys.exit(1)
    sys.exit(0)


if __name__ == '__main__':
    main()
