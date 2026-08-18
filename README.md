# com.flow.eleventy

`com.flow.eleventy` is a [DITA Open Toolkit](https://www.dita-ot.org/) plug-in that adds YAML front matter to HTML generated from DITA topics. The output is intended for use as Eleventy content.

The plug-in extends the DITA-OT HTML5 transformation and provides the `eleventy` transtype.

## Install

Install the plug-in into your DITA-OT installation:

```sh
dita --install path/to/com.flow.eleventy
```

Restart DITA-OT if required by your installation.

## Build

Run the `eleventy` transtype against a DITA map or topic:

```sh
dita -i input.ditamap -f eleventy -o out
```

The transformation uses the HTML5 processing pipeline, generates a partial navigation table of contents, and writes HTML files containing YAML front matter followed by the topic body markup. The surrounding HTML document and `<body>` element are deliberately omitted so that an Eleventy layout can supply them.

## Generated front matter

Every generated file includes these fields:

- `layout` - `base` by default; set with `-Djekyll.layout=name`
- `title` - topic title
- `index` - path to the generated table of contents
- `src` - source topic path

The following fields are included when their DITA source values are present:

- `description` - topic short description (including one in an abstract)
- `category` - distinct `<category>` values, joined with commas
- `keywords` - distinct `<keyword>` values, joined with commas
- `audience` - distinct `<audience>` values or `othermeta` values named `audience`
- additional `othermeta` values - each `othermeta` `name` becomes a front-matter key; repeated distinct values become a YAML list
- `commit` - set with `-Dcommit=value`
- `generated: true` - when the topic, or its title, has `outputclass="generated"`

All string values are single-quoted and apostrophes are escaped for valid YAML.
