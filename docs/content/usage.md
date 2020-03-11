---
title: "MuShop Docs"
date: 2020-03-10T10:02:31-06:00
draft: true
weight: 1000
---

Project documentation built with [Hugo](https://gohugo.io/) and customized [UIkit](https://getuikit.com) theme.

## Setup

1. Install documentation theme:

    ```sh
    make theme
    ```

1. Install [`hugo` CLI](https://gohugo.io/getting-started/installing/):

    ```sh
    brew install hugo
    ```

## Development

In general, the content management follows all the standard features of Hugo.

- [Hugo Content Management](https://gohugo.io/content-management/)

### Start hugo server

```sh
make up
```

Or with `hugo`:

```sh
hugo server --buildDrafts
```

### Add Content

1. Create content as follows:

    - Create a new section: `hugo new <section>/_index.md`
    - Create a new lab topic: `hugo new labs/<topic>/_index.md`
    - Create a new lab page: `hugo new labs/<topic>/<page>.md`

1. Edit [front matter](https://gohugo.io/content-management/front-matter/)

    ```yaml
    ---
    title: "My New Content"
    description: "short description of content"
    draft: false
    hidden: false
    weight: 20 # ordering by weight
    keywords:
      - one
      - two
    tags:
      - advanced
      - oke
    ###### Custom ######
    # breadcrumbs
    disableBreadcrumb: false
    # footer navigation
    disablePrevNext: false
    disablePrev: false
    disableNext: false
    # section options
    showChildren: false # lists child pages of the section/_index.md
    orderedChildren: false # use ordered list for child pages
    ---
    ```

## Features

The Hugo documentation theme is custom-built with [UIkit](https://getuikit.com/docs/) components (just like MuShop storefront).

### Code Settings

- **Helm**: Displays code blocks specific to helm version

    ```text
      ```shell--helm2
      helm install ./mushop --name mymushop
      ```

      ```shell--helm3
      helm install mymushop ./mushop
      ```
    ```

- **OS**: Displays code blocks specific to os

    ```text
      ```shell--linux-macos
      export MUSHOP_NAMESPACE=mushop
      ```

      ```shell--win
      set MUSHOP_NAMESPACE=mushop
      ```
    ```

### Shortcodes

Add panache to the documentation using these custom shortcodes

#### Alert

> Displays an alert style block. Specify icon from the UIkit [icon library](https://getuikit.com/docs/icon#library)

`alert <style="(default|primary|success|warning|danger)"> <icon="">`

```markdown
{{%/* alert style="success" icon="check" */%}}
Alert content to `process` as markdown
{{%/* /alert */%}}
```

{{% alert style="success" icon="check" %}}
Alert content to `process` as markdown
{{% /alert %}}

#### Aspect Ratio

> Fix the enclosed content to an aspect ratio.

`aspect <ratio="(1-1|3-2|4-3|16-9|2-1)"> [class="..."]`

{{% aspect ratio="2-1" class="uk-margin-bottom" %}}
{{% wrapper "uk-background-primary uk-light uk-padding-small" %}}
Content with aspect ratio of `2-1`
{{% /wrapper %}}
{{% /aspect %}}

```markdown
{{%/* aspect ratio="2-1" class="uk-margin-bottom" */%}}
{{%/* wrapper "uk-background-primary uk-light uk-padding-small" */%}}
Content with aspect ratio of `2-1`
{{%/* /wrapper */%}}
{{%/* /aspect */%}}
```

#### Grid

> Add a grid of inner contents using [grid](https://getuikit.com/docs/grid) and [flex](https://getuikit.com/docs/flex)

`grid [...]`

Supports the following options:

- `options`: See [docs](https://getuikit.com/docs/grid#component-options)
- `class`: Any classes to add to the grid wrapper
- `col`: Child element column [width](https://getuikit.com/docs/width)
- `breakpoint`: `(s|m|l|xl)` breakpoint at which the child element width becomes grid vs stacked. Default `m`
- `gutter`: `(small|medium|large|collapse)` gutter settings (optional)
- `x`: horizontal flex alignment see [here](https://getuikit.com/docs/flex#horizontal-alignment)
- `y`: vertical flex alignment see [here](https://getuikit.com/docs/flex#vertical-alignment)

{{% grid col="1-3" %}}
- **Example**
- Item one
- Item two
{{% /grid %}}

```markdown
{{%/* grid col="1-3" */%}}
- **Example**
- Item one
- Item two
{{%/* /grid */%}}
```

#### Icon

> Add any icon from the [library](https://getuikit.com/docs/icon#library)

`icon <name> [ratio]`

{{< icon "bookmark" "3.5" >}}

```text
{{</* icon "bookmark" "3.5" */>}}
```

#### Switcher

> Create a left-tab switcher component

`switcher <...tabs>`

{{< switcher "One" "Two" "Three" >}}
- Tab one content
    ```ts
    const foo: string = 'blah blah';
    ```
- Tab two content
- Tab three content
{{< /switcher >}}

```markdown
{{</* switcher "One" "Two" "Three" */>}}
- Tab one content
    ```ts
    const foo: string = 'blah blah';
    ```
- Tab two content
- Tab three content
{{</* /switcher */>}}
```

#### Width

> Specify inner width after breakpoint according to the [docs](https://getuikit.com/docs/width)

`width <width> [breakpoint]`

{{% width "1-3" "s" %}}
{{% alert style="danger" %}}
![image](../images/oracle.svg)
{{% /alert %}}
{{% /width %}}

```markdown
{{%/* width "1-3" "s" */%}}
{{%/* alert style="danger" */%}}
![image](../images/oracle.svg)
{{%/* /alert */%}}
{{%/* /width */%}}
```

#### Wrapper

> Wraps inner content with any `div` and specified classes. Useful for specifying markup with other UIkit features

`wrapper [classes]`

{{% wrapper "uk-width-1-4@s uk-light uk-background-primary uk-panel uk-padding uk-margin-bottom" %}}
Light Panel
{{% /wrapper %}}

```markdown
{{%/* wrapper "uk-width-1-4@s uk-light uk-background-primary uk-panel uk-padding uk-margin-bottom" */%}}
Light Panel
{{%/* /wrapper */%}}
```

#### Mermaid

> SVG diagrams from [mermaid](https://mermaid-js.github.io/mermaid/#/)

`mermaid`

{{< mermaid >}}
graph LR
  A[Hard edge] -->|Link text| B(Round edge)
  B --> C{Decision}
  C -->|One| D[Result one]
  C -->|Two| E[Result two]
{{< /mermaid >}}

```markdown
{{</* mermaid */>}}
graph LR
  A[Hard edge] -->|Link text| B(Round edge)
  B --> C{Decision}
  C -->|One| D[Result one]
  C -->|Two| E[Result two]
{{</* /mermaid */>}}
```
