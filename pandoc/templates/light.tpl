<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  $if(title)$<title>$title$</title>$endif$
  <style>
    body {
      max-width: $if(css_body_max_width)$$css_body_max_width$$else$none$endif$;
      margin: auto;
      padding: 1rem;
      font-family: 'Noto Sans', sans-serif;
      word-wrap: break-word;
    }

    pre, code {
      font-family: monospace;
      white-space: $if(css_code_white_space)$$css_code_white_space$$else$none$endif$;
      max-width: $if(css_code_max_width)$$css_code_max_width$$else$none$endif$;
      overflow-x: auto;
      background-color: #eeeeee;
      margin: 1em 0;
      padding: 0.5em;
      border: none;
      line-height: 1.5;
    }

    code {
      padding: 0.15em 0.4em;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin: 1rem 0;
      font-size: 1em;
      font-family: 'Noto Sans', sans-serif;
      background-color: #f9f9f9;
    }

    th, td {
      padding: 0.5rem;
      border: 1px solid #dddddd;
      text-align: left;
    }

    th {
      background-color: #e8e8e8;
      font-weight: bold;
    }

    tr {
      background-color: #ffffff;
    }

    a {
        text-decoration: none;
    }

    a:hover {
        text-decoration: underline;
    }
  </style>
</head>
<body>
  $body$
</body>
</html>
