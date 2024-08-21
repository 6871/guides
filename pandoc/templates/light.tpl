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
      line-height: 1.4;
    }

    pre {
      font-family: monospace;
      white-space: $if(css_pre_white_space)$$css_pre_white_space$$else$none$endif$;
      max-width: $if(css_pre_max_width)$$css_pre_max_width$$else$none$endif$;
      overflow-x: auto;
      background-color: #eeeeee;
      margin: 1em 0;
      padding: 1em;
      border: none;
      line-height: 1.4;
    }

    code {
      font-family: monospace;
      padding: 0.15em 0.4em;
      background-color: #eeeeee;
    }

    pre code {
      padding: 0; /* prevent first line of pre blocks indenting */
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

    li {
      margin-bottom: 0.125em;
    }

    li:last-child {
      margin-bottom: 0;
    }
  </style>
</head>
<body>
  $body$
</body>
</html>
