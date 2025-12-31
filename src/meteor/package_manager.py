"""Package manager for Meteor language (MPM - Meteor Package Manager).

Handles meteor.toml parsing, dependency resolution, and package management.
"""

import os
import re
from typing import Optional, Dict, List, Any
from dataclasses import dataclass, field


@dataclass
class Dependency:
    """A package dependency."""
    name: str
    version: Optional[str] = None
    git: Optional[str] = None
    path: Optional[str] = None

    def __str__(self) -> str:
        if self.git:
            return f"{self.name} (git: {self.git})"
        elif self.path:
            return f"{self.name} (path: {self.path})"
        else:
            return f"{self.name} = {self.version}"


@dataclass
class PackageInfo:
    """Package metadata from meteor.toml."""
    name: str
    version: str = "0.1.0"
    description: str = ""
    authors: List[str] = field(default_factory=list)
    license: str = ""
    repository: str = ""
    keywords: List[str] = field(default_factory=list)

    # Build configuration
    entry_point: str = "main.met"
    output_dir: str = "build"

    # Dependencies
    dependencies: Dict[str, Dependency] = field(default_factory=dict)
    dev_dependencies: Dict[str, Dependency] = field(default_factory=dict)


class TomlParser:
    """Simple TOML parser for meteor.toml files."""

    def __init__(self, content: str):
        self.content = content
        self.pos = 0
        self.line = 1

    def parse(self) -> Dict[str, Any]:
        """Parse TOML content into a dictionary."""
        result = {}
        current_section = result
        current_section_name = None

        for line in self.content.split('\n'):
            line = line.strip()
            self.line += 1

            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue

            # Section header
            if line.startswith('['):
                section_name = self._parse_section_header(line)
                current_section_name = section_name

                # Handle nested sections like [dependencies]
                parts = section_name.split('.')
                current_section = result
                for part in parts:
                    if part not in current_section:
                        current_section[part] = {}
                    current_section = current_section[part]
            else:
                # Key-value pair
                key, value = self._parse_key_value(line)
                current_section[key] = value

        return result

    def _parse_section_header(self, line: str) -> str:
        """Parse a section header like [package] or [dependencies]."""
        match = re.match(r'\[([^\]]+)\]', line)
        if not match:
            raise ValueError(f"Invalid section header at line {self.line}: {line}")
        return match.group(1).strip()

    def _parse_key_value(self, line: str) -> tuple:
        """Parse a key-value pair."""
        if '=' not in line:
            raise ValueError(f"Invalid key-value pair at line {self.line}: {line}")

        key, value = line.split('=', 1)
        key = key.strip()
        value = value.strip()

        # Parse value
        parsed_value = self._parse_value(value)
        return key, parsed_value

    def _parse_value(self, value: str) -> Any:
        """Parse a TOML value."""
        # String
        if value.startswith('"') and value.endswith('"'):
            return value[1:-1]
        if value.startswith("'") and value.endswith("'"):
            return value[1:-1]

        # Boolean
        if value.lower() == 'true':
            return True
        if value.lower() == 'false':
            return False

        # Number
        try:
            if '.' in value:
                return float(value)
            return int(value)
        except ValueError:
            pass

        # Array
        if value.startswith('[') and value.endswith(']'):
            return self._parse_array(value)

        # Inline table
        if value.startswith('{') and value.endswith('}'):
            return self._parse_inline_table(value)

        return value

    def _parse_array(self, value: str) -> List[Any]:
        """Parse a TOML array."""
        content = value[1:-1].strip()
        if not content:
            return []

        items = []
        for item in content.split(','):
            item = item.strip()
            if item:
                items.append(self._parse_value(item))
        return items

    def _parse_inline_table(self, value: str) -> Dict[str, Any]:
        """Parse a TOML inline table."""
        content = value[1:-1].strip()
        if not content:
            return {}

        result = {}
        for pair in content.split(','):
            pair = pair.strip()
            if '=' in pair:
                key, val = pair.split('=', 1)
                result[key.strip()] = self._parse_value(val.strip())
        return result


class PackageManager:
    """Meteor Package Manager (MPM).

    Handles package discovery, dependency resolution, and module paths.
    """

    MANIFEST_FILE = "meteor.toml"

    def __init__(self, project_root: Optional[str] = None):
        """Initialize the package manager.

        Args:
            project_root: Root directory of the project
        """
        self.project_root = project_root or os.getcwd()
        self.package_info: Optional[PackageInfo] = None
        self._packages_dir = os.path.join(self.project_root, ".meteor", "packages")

    def load_manifest(self) -> Optional[PackageInfo]:
        """Load and parse meteor.toml from project root."""
        manifest_path = os.path.join(self.project_root, self.MANIFEST_FILE)

        if not os.path.isfile(manifest_path):
            return None

        with open(manifest_path, 'r', encoding='utf-8') as f:
            content = f.read()

        parser = TomlParser(content)
        data = parser.parse()

        self.package_info = self._parse_package_info(data)
        return self.package_info

    def _parse_package_info(self, data: Dict[str, Any]) -> PackageInfo:
        """Parse package info from TOML data."""
        pkg = data.get('package', {})

        info = PackageInfo(
            name=pkg.get('name', 'unnamed'),
            version=pkg.get('version', '0.1.0'),
            description=pkg.get('description', ''),
            authors=pkg.get('authors', []),
            license=pkg.get('license', ''),
            repository=pkg.get('repository', ''),
            keywords=pkg.get('keywords', []),
            entry_point=pkg.get('entry_point', 'main.met'),
            output_dir=pkg.get('output_dir', 'build'),
        )

        # Parse dependencies
        deps = data.get('dependencies', {})
        for name, value in deps.items():
            info.dependencies[name] = self._parse_dependency(name, value)

        # Parse dev dependencies
        dev_deps = data.get('dev-dependencies', {})
        for name, value in dev_deps.items():
            info.dev_dependencies[name] = self._parse_dependency(name, value)

        return info

    def _parse_dependency(self, name: str, value: Any) -> Dependency:
        """Parse a dependency specification."""
        if isinstance(value, str):
            return Dependency(name=name, version=value)
        elif isinstance(value, dict):
            return Dependency(
                name=name,
                version=value.get('version'),
                git=value.get('git'),
                path=value.get('path'),
            )
        else:
            return Dependency(name=name)

    def get_module_search_paths(self) -> List[str]:
        """Get list of paths to search for modules."""
        paths = [self.project_root]

        # Add src directory if it exists
        src_dir = os.path.join(self.project_root, 'src')
        if os.path.isdir(src_dir):
            paths.append(src_dir)

        # Add packages directory
        if os.path.isdir(self._packages_dir):
            paths.append(self._packages_dir)

        return paths

    def init_project(self, name: str) -> str:
        """Initialize a new Meteor project.

        Args:
            name: Project name

        Returns:
            Path to created meteor.toml
        """
        manifest_content = f'''[package]
name = "{name}"
version = "0.1.0"
description = ""
authors = []

[dependencies]
'''
        manifest_path = os.path.join(self.project_root, self.MANIFEST_FILE)
        with open(manifest_path, 'w', encoding='utf-8') as f:
            f.write(manifest_content)

        # Create src directory
        src_dir = os.path.join(self.project_root, 'src')
        os.makedirs(src_dir, exist_ok=True)

        # Create main.met
        main_path = os.path.join(src_dir, 'main.met')
        with open(main_path, 'w', encoding='utf-8') as f:
            f.write('# Main entry point\n\ndef main()\n    print("Hello, Meteor!")\n')

        return manifest_path
