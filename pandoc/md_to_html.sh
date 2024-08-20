#!/usr/bin/env bash
function md-to-html {
  # Run Pandoc in a Docker container to convert a host markdown file to html.
  if [ $# -lt 1 ]; then
    printf "Error: No input file specified.\n"
    printf 'Usage: md-file-to-html'
    printf ' <input-file>'
    printf ' [--output-file <output-file>]'
    printf ' [--dark]'
    printf ' [--light]'
    printf ' [--css-body-max-width <value>]'
    printf ' [--css-code-white-space <value>]'
    printf ' [--css-code-max-width <value>]\n'
    return 64
  fi

  if [ ! -e "$1" ]; then
    printf 'Error: input file "%s" not found\n' "$1" >&2
    return 65
  fi

  local input_file
  input_file="$(realpath -- "${1:?}")"  # Absolute path for Docker
  shift 1
  printf 'input_file : %s\n' "${input_file}" >&2

  local docker_image='pandoc'

  if ! docker image inspect "${docker_image:?}" > /dev/null 2>&1; then
    printf 'Error: Docker image %s does not exist\n' "${docker_image}" >&2
    printf 'Locate Dockerfile and build with: docker build --tag %s .\n' "${docker_image:?}" >&2
    return 66
  fi

  local css_body_max_width='none'  # uses available width
  local css_code_white_space='none'  # use pre-wrap to wrap instead of scroll
  local css_code_max_width='none'  # uses available width
  local css_template_dir='/pandoc/templates/'
  local css_template_dark="${css_template_dir:?}dark.tpl"
  local css_template_light="${css_template_dir:?}light.tpl"
  local css_template="${css_template_light:?}"  # default

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --output)
        local output_file="${2:?}"
        shift 2
        ;;
      --output=*)
        local output_file="${1#*=}"
        shift 1
        ;;
      --light)
        css_template="${css_template_light:?}"
        shift 1
        ;;
      --dark)
        css_template="${css_template_dark:?}"
        shift 1
        ;;
      --css-body-max-width)
        css_body_max_width="${2:?}"
        shift 2
        ;;
      --css-body-max-width=*)
        css_body_max_width="${1#*=}"
        shift 1
        ;;
      --css-code-white-space)
        css_code_white_space="${2:?}"
        shift 2
        ;;
      --css-code-white-space=*)
        css_code_white_space="${1#*=}"
        shift 1
        ;;
      --css-code-max-width)
        css_code_max_width="${2:?}"
        shift 2
        ;;
      --css-code-max-width=*)
        css_code_max_width="${1#*=}"
        shift 1
        ;;
      *)
        printf 'Error: unknown option: %s\n' "$1" >&2
        return 67
        ;;
    esac
  done

  local output_file="${output_file:-"${input_file:?}.html"}"

  if [[ "$output_file" != /* ]]; then
    printf 'output_file is not absolute, appending current directory\n' >&2
    output_file="${PWD:?}/${output_file}"
  fi

  printf 'output_file: %s\n' "${output_file}" >&2

  if [ -e "${output_file:?}" ]; then
    printf 'Error: output file %s already exists\n' "${output_file}" >&2
    return 68
  fi

  docker \
    run \
      --rm \
      --mount "type=bind,source=${input_file:?},target=/host/input_file,readonly" \
      --name "pandoc-$(date +%s)" \
      --network none \
      "${docker_image:?}" \
        -f markdown \
        -t html5 \
        --template="${css_template:?}" \
        --standalone \
        --metadata title="$(basename -- "${input_file:?}")" \
        --metadata css_body_max_width="${css_body_max_width:?}" \
        --metadata css_code_white_space="${css_code_white_space:?}" \
        --metadata css_code_max_width="${css_code_max_width:?}" \
        /host/input_file \
  > "${output_file:?}"
}
