#!/bin/bash

# Single source of truth for public resume variants and their build metadata.
readonly RESUME_VARIANTS=(default java backend fullstack english)

resolve_variant() {
  local requested="$1"
  OUTPUT_MODE="zh"

  case "${requested}" in
    default|general|resume)
      VARIANT_KEY="default"
      SOURCE_FILE="zh/default.md"
      POSITION="通用简历"
      OUTPUT_SLUG="General"
      ;;
    java)
      VARIANT_KEY="java"
      SOURCE_FILE="zh/java.md"
      POSITION="Java开发工程师"
      OUTPUT_SLUG="Java-Engineer"
      ;;
    backend)
      VARIANT_KEY="backend"
      SOURCE_FILE="zh/backend.md"
      POSITION="后端开发工程师"
      OUTPUT_SLUG="Backend-Engineer"
      ;;
    fullstack)
      VARIANT_KEY="fullstack"
      SOURCE_FILE="zh/fullstack.md"
      POSITION="全栈开发工程师"
      OUTPUT_SLUG="Fullstack-Engineer"
      ;;
    english|en)
      VARIANT_KEY="english"
      SOURCE_FILE="en/default.md"
      POSITION="General Resume"
      OUTPUT_SLUG="General"
      OUTPUT_MODE="en"
      ;;
    *)
      return 1
      ;;
  esac
}
