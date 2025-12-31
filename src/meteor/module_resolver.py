"""Module resolver for Meteor language.

Handles the mapping of module names to file paths and module loading.
Implements "file as module" design where import math.vector maps to math/vector.met.
"""

import os
from typing import Optional, Dict, List, Set
from dataclasses import dataclass, field


@dataclass
class ModuleInfo:
    """Information about a resolved module."""
    name: str                    # Full module name (e.g., "math.vector")
    file_path: str               # Absolute path to .met file
    is_public: bool = False      # Whether module is public
    exports: Dict[str, bool] = field(default_factory=dict)  # symbol -> is_public
    dependencies: List[str] = field(default_factory=list)   # List of imported modules


class ModuleResolver:
    """Resolves module names to file paths.

    Implements the "file as module" design:
    - import math.vector -> math/vector.met
    - from math import sin -> math.met (imports sin symbol)
    """

    def __init__(self, project_root: str, search_paths: Optional[List[str]] = None):
        """Initialize the module resolver.

        Args:
            project_root: Root directory of the project
            search_paths: Additional paths to search for modules
        """
        self.project_root = os.path.abspath(project_root)
        self.search_paths = [self.project_root]

        # Add standard library path (parent of std/)
        meteor_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        meteor_base = os.path.join(meteor_root, '..')
        if os.path.isdir(os.path.join(meteor_base, 'std')):
            self.search_paths.append(os.path.abspath(meteor_base))

        if search_paths:
            self.search_paths.extend(search_paths)

        # Cache of resolved modules
        self._cache: Dict[str, ModuleInfo] = {}
        # Set of modules currently being resolved (for cycle detection)
        self._resolving: Set[str] = set()

    def resolve(self, module_name: str, from_file: Optional[str] = None) -> Optional[ModuleInfo]:
        """Resolve a module name to its file path.

        Args:
            module_name: Dotted module name (e.g., "math.vector")
            from_file: File that is importing this module (for relative imports)

        Returns:
            ModuleInfo if found, None otherwise
        """
        # Check cache first
        if module_name in self._cache:
            return self._cache[module_name]

        # Check for circular imports
        if module_name in self._resolving:
            raise ImportError(f"Circular import detected: {module_name}")

        self._resolving.add(module_name)

        try:
            # Convert module name to path
            rel_path = module_name.replace('.', os.sep) + '.met'

            # Search in all paths
            for search_path in self._get_search_paths(from_file):
                full_path = os.path.join(search_path, rel_path)
                if os.path.isfile(full_path):
                    info = ModuleInfo(
                        name=module_name,
                        file_path=os.path.abspath(full_path)
                    )
                    self._cache[module_name] = info
                    return info

            return None
        finally:
            self._resolving.discard(module_name)

    def _get_search_paths(self, from_file: Optional[str]) -> List[str]:
        """Get search paths for module resolution.

        Args:
            from_file: File that is importing (for relative imports)

        Returns:
            List of paths to search
        """
        paths = list(self.search_paths)

        # Add directory of importing file for relative imports
        if from_file:
            from_dir = os.path.dirname(os.path.abspath(from_file))
            if from_dir not in paths:
                paths.insert(0, from_dir)

        return paths

    def get_module_exports(self, module_info: ModuleInfo) -> Dict[str, bool]:
        """Get exported symbols from a module.

        Args:
            module_info: Module to get exports from

        Returns:
            Dict mapping symbol names to their public status
        """
        # This will be populated during module parsing
        return module_info.exports

    def clear_cache(self):
        """Clear the module cache."""
        self._cache.clear()


class ModuleLoader:
    """Loads and parses Meteor modules."""

    def __init__(self, resolver: ModuleResolver):
        """Initialize the module loader.

        Args:
            resolver: Module resolver to use
        """
        self.resolver = resolver
        self._loaded: Dict[str, 'ModuleInfo'] = {}

    def load(self, module_name: str, from_file: Optional[str] = None):
        """Load a module by name.

        Args:
            module_name: Dotted module name
            from_file: File that is importing this module

        Returns:
            Parsed module AST and exports
        """
        # Resolve module path
        info = self.resolver.resolve(module_name, from_file)
        if not info:
            raise ImportError(f"Module not found: {module_name}")

        # Check if already loaded
        if module_name in self._loaded:
            cached = self._loaded[module_name]
            return cached, None  # Return cached info, no AST needed

        # Parse the module file
        from meteor.lexer import Lexer
        from meteor.parser import Parser

        with open(info.file_path, 'r', encoding='utf-8') as f:
            source = f.read()

        lexer = Lexer(source, info.file_path)
        parser = Parser(lexer)
        ast = parser.parse()

        # Extract exports (symbols marked with pub)
        info.exports = self._extract_exports(ast)
        self._loaded[module_name] = info

        return info, ast

    def _extract_exports(self, ast) -> Dict[str, bool]:
        """Extract exported symbols from module AST.

        Args:
            ast: Parsed module AST

        Returns:
            Dict mapping symbol names to True (all exports are public)
        """
        from meteor.ast import PublicDecl, FuncDecl, ClassDeclaration
        from meteor.ast import TraitDeclaration, EnumDeclaration, ErrorDeclaration

        exports = {}

        for child in ast.block.children:
            if isinstance(child, PublicDecl):
                decl = child.declaration
                if isinstance(decl, FuncDecl):
                    exports[decl.name] = True
                elif isinstance(decl, ClassDeclaration):
                    exports[decl.name] = True
                elif isinstance(decl, TraitDeclaration):
                    exports[decl.name] = True
                elif isinstance(decl, EnumDeclaration):
                    exports[decl.name] = True
                elif isinstance(decl, ErrorDeclaration):
                    exports[decl.name] = True

        return exports
