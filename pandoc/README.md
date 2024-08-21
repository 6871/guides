# Pandoc Docker wrapper

To run Pandoc in a Docker container and convert host markdown files to HTML:

1. Build a `pandoc` Docker image from the project's [Dockerfile](Dockerfile):

    ```bash
    docker build --tag pandoc .
    ```
   
2. Load the `md-to-html` helper function in [md_to_html.sh](md_to_html.sh) into the shell:

    ```bash
    source md_to_html.sh
    ```

    Function `md-to-html` runs Pandoc in a container using the above image; it accepts the following arguments:
 
    | Argument                          | Description                                                                                                |
    |-----------------------------------|------------------------------------------------------------------------------------------------------------|
    | `<input-file>`                    | The markdown file to convert to HTML.                                                                      |
    | `[--output <output-file>]`        | Output HTML file name; defaults to `input-file` with extension `.html`.                                    |
    | `[--dark]`                        | Create output HTML file with a dark theme.                                                                 |
    | `[--light]`                       | Create output HTML file with a light theme (default).                                                      |
    | `[--css-body-max-width <value>]`  | CSS `max-width` value for HTML `<body>` element; defaults to `none`; can be `80ch`, `50%`, etc.            |
    | `[--css-pre-white-space <value>]` | CSS `white-space` setting for HTML `<pre>` elements; defaults to `pre`; use `pre-wrap` to wrap not scroll. |
    | `[--css-pre-max-width <value>]`   | CSS `max-width` value for HTML `<pre>` elements; defaults to `none`; can be `80ch`, `50%`, etc.            |
 
    ℹ️ The `--css-*` argument values map to embedded CSS values in the supplied Pandoc [templates](templates).
 
3. Use the `md-to-html` helper function to convert a host markdown file to HTML; e.g.:

    ```bash
    md-to-html README.md
    ```
    
    ```bash
    open README.md.html
    ```
