"""
PyCommon - Common utilities for genealogy projects.

Private shared library for genealogy, metadata, and media-tagging projects.
"""

__version__ = "0.1.0"

from .ramdisk import RAMDisk, RAMDiskContext, get_ramdisk_stats, log_ramdisk_info
from .env import (
    MEDIA_INPUT,
    MEDIA_PROCESSED,
    METADATA_ROOT,
    check_environment_variables,
    persons_dir,
    locations_file,
    locations_dir,
    extracted_photos_dir,
    ensure_dir,
)

__all__ = [
    # RAMDisk utilities
    "RAMDisk",
    "RAMDiskContext",
    "get_ramdisk_stats",
    "log_ramdisk_info",
    # Environment variables and path utilities
    "MEDIA_INPUT",
    "MEDIA_PROCESSED",
    "METADATA_ROOT",
    "check_environment_variables",
    "persons_dir",
    "locations_file",
    "locations_dir",
    "extracted_photos_dir",
    "ensure_dir",
]
