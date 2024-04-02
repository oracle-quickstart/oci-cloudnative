---
title: "MuShop Docs"
date: 2020-03-10T10:02:31-06:00
draft: false
hidden: true
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
- [Hugo Shortcodes](https://gohugo.io/content-management/shortcodes)
- [Cross Referencing](https://gohugo.io/content-management/cross-references/)

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
      helm upgrade --install mymushop ./mushop
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

### Shortcode Components

Add panache to the documentation using these custom shortcodes directly within
markdown documents.

#### Alert

> Displays an alert style block. Specify icon from the UIkit [icon library](https://getuikit.com/docs/icon#library)

{{% grid col="1-2" y="top" %}}

```markdown
{{%/* alert style="primary" icon="info" */%}}
Alert content `processed` as **markdown**
{{%/* /alert */%}}
```

{{% wrapper %}}
{{% alert style="primary" icon="info" %}}
Alert content `processed` as **markdown**
{{% /alert %}}
{{% alert style="success" icon="check" %}}
Alert content `processed` as **markdown**
{{% /alert %}}
{{% alert style="warning" icon="warning" %}}
Alert content `processed` as **markdown**
{{% /alert %}}
{{% alert style="danger" icon="ban" %}}
Alert content `processed` as **markdown**
{{% /alert %}}
{{% /wrapper %}}

{{% /grid %}}

| Options | |
|--|--|
| `style` |  `default|primary|success|warning|danger` |
| `icon` | Icon from [library](https://getuikit.com/docs/icon#library) |
| `class` | Additional classes |

---

#### Aspect Ratio

> Fix the enclosed content to an aspect ratio.

{{% grid col="1-2" y="top" %}}

```markdown
{{%/* aspect ratio="2-1" */%}}
{{%/* wrapper "uk-background-muted uk-padding-small" */%}}
Content with aspect ratio of `2-1`
{{%/* /wrapper */%}}
{{%/* /aspect */%}}
```

{{% wrapper %}}
{{% aspect ratio="2-1" %}}
{{% wrapper "uk-background-muted uk-padding-small" %}}
Content with aspect ratio of `2-1`
{{% /wrapper %}}
{{% /aspect %}}
{{% /wrapper %}}

{{% /grid %}}

| Options | |
|--|--|
| `ratio` |  `1-1|3-2|4-3|16-9|2-1` |
| `class` | Additional classes |

---

#### Card

> Display content as cards - usually in a grid

{{% grid col="1-2" y="top" %}}

```markdown
{{%/* grid col="1-2" */%}}
{{%/* card style="primary" title="Primary" hover=true */%}}
Card body
{{%/* /card */%}}
{{%/* card style="secondary" title="Secondary" */%}}
Card body
{{%/* /card */%}}
{{%/* /grid */%}}
```

{{% wrapper %}}
{{% grid col="1-2" %}}
{{% card style="primary" title="Primary" hover=true %}}
Card body
{{% /card %}}
{{% card style="secondary" title="Secondary" %}}
Card body
{{% /card %}}
{{% /grid %}}
{{% /wrapper %}}

{{% /grid %}}

| Options | |
|--|--|
| `style` |  `default|primary|secondary` |
| `size` |  `small|large` |
| `hover` | Add hover styling |
| `title` | Card title |
| `width` | Width ratio accodring to [width](https://getuikit.com/docs/width) |
| `class` | Additional classes |

---

#### Grid

> Add a grid of inner contents using [grid](https://getuikit.com/docs/grid) and [flex](https://getuikit.com/docs/flex)

{{% grid col="1-2" y="top" %}}

```markdown
{{%/* grid col="1-3" */%}}
- **Example**
- Item one
- Item two
{{%/* /grid */%}}
```

{{% wrapper %}}
{{% grid col="1-3" %}}

- **Example**
- Item one
- Item two
{{% /grid %}}
{{% /wrapper %}}
{{% /grid %}}

| Options | |
|--|--|
| `gutter` | `small|medium|large|collapse` gutter settings (optional) |
| `class` | Any classes to add to the grid wrapper |
| `col` | Child element column [width](https://getuikit.com/docs/width) |
| `breakpoint` | `(s|m|l|xl)` breakpoint at which the child element width becomes grid vs stacked. Default `m` |
| `x` | horizontal flex alignment see [here](https://getuikit.com/docs/flex#horizontal-alignment) |
| `y` | vertical flex alignment see [here](https://getuikit.com/docs/flex#vertical-alignment) |
| `options` | See [docs](https://getuikit.com/docs/grid#component-options) |

---

#### Icon

> Add any icon from the [library](https://getuikit.com/docs/icon#library)

{{% grid col="1-2" y="top" %}}
```text
{{</* icon "bookmark" "2.5" */>}}
```

{{< icon "bookmark" "2.5" >}}
{{% /grid %}}

| Options | |
|--|--|
| `icon` | Icon name |
| `ratio` | Size proportion |

---

#### Overflow

> Applies automatic overflow to the contents. Useful with [aspect ratio](#aspect-ratio) and `table` contents

{{% grid col="1-2" y="top" %}}
```text
{{%/* overflow */%}}
Something very tall or wide
{{%/* /overflow */%}}
```

{{% overflow %}}
Something very wide
{{% /overflow %}}
{{% /grid %}}

| Arguments | |
|--|--|
| `[class]` | CSS class string to apply to wrapper `<div>` element |
| `[attr]` | Attributes to apply to wrapper `<div>` element |

---

#### Slideshow

> Display list items as a slideshow

{{% grid col="1-2" y="top" %}}

```html
{{%/* slideshow dotnav=true */%}}
{{%/* list/item "uk-background-secondary uk-light uk-padding" */%}}
Slide one `markdown` CONTENT
{{%/* /list/item */%}}
<li class="uk-background-primary uk-light uk-padding">
  Slide two HTML content
</li>
{{%/* /slideshow */%}}
```

{{% slideshow dotnav=true class="uk-light" %}}
{{% list/item "uk-background-secondary uk-padding" %}}
  Slide one `markdown` content
{{% /list/item %}}

<li class="uk-background-primary uk-padding">
  Slide two HTML content
</li>
{{% /slideshow %}}
{{% /grid %}}

| Options | |
|--|--|
| `options` | See [options](https://getuikit.com/docs/slideshow#component-options) |
| `class` | CSS class(es) to add to the slideshow items container |
| `attrs` | DOM attributes to add to the `ul` items wrapper |
| `dotnav` | Bool to include dotnav below slideshow |

{{% alert style="warning" icon="warning" %}}
Slideshow items must be `<li>` type. Refer to [usage](https://getuikit.com/docs/slideshow#usage) for specific decorations for the desired presentation
{{% /alert %}}

---

#### Switcher

> Create a tabbed content switcher

{{% grid col="1-2" y="top" %}}

```markdown
{{</* switcher left=true tabs="One|Two|Three" */>}}
- Tab one content
    ```ts
    const foo: string = 'bar';
    ```
- Tab two content
- Tab three content
{{</* /switcher */>}}
```

{{% wrapper %}}
{{< switcher left=true tabs="One|Two|Three" >}}

- Tab one content

    ```ts
    const foo: string = 'bar';
    ```

- Tab two content
- Tab three content
{{< /switcher >}}
{{% /wrapper %}}
{{% /grid %}}

| Options | |
|--|--|
| `tabs` | Switcher tab names delimited by `|` |
| `class` | CSS class(es) to add to the slideshow items container |
| `left` | Set to `true` for tabs on the left |

---

#### Width

> Specify inner width after breakpoint according to the [docs](https://getuikit.com/docs/width)

`width <width> [breakpoint]`

{{% grid col="1-2" y="top" %}}

```markdown
{{%/* width "1-2" "s" */%}}
{{%/* alert style="danger" */%}}
![image](../images/oracle.svg)
{{%/* /alert */%}}
{{%/* /width */%}}
```
{{% wrapper %}}
{{% width "1-2" "s" %}}
{{% alert style="danger" %}}
![image](../images/oracle.svg)
{{% /alert %}}
{{% /width %}}
{{% /wrapper %}}
{{% /grid %}}

| Arguments | |
|--|--|
| `<width>` | Content width ratio |
| `[breakpoint]` | `s|m|l|xl` Size at which the width should apply |

---

#### Wrapper

> Wraps inner content with any `div` and specified classes. Useful for specifying markup with other UIkit features

{{% grid col="1-2" y="top" %}}

```markdown
{{%/* wrapper "uk-light uk-background-primary uk-panel uk-padding" */%}}
Light Panel
{{%/* /wrapper */%}}
```

{{% wrapper %}}
{{% wrapper "uk-light uk-background-primary uk-panel uk-padding" %}}
Light Panel
{{% /wrapper %}}
{{% /wrapper %}}
{{% /grid %}}

| Arguments | |
|--|--|
| `[class]` | CSS class string to apply to wrapper `<div>` element |
| `[attr]` | Attributes to apply to wrapper `<div>` element |

---

### Shortcode Extras

#### Diagrams

> Markdownish SVG diagrams from [mermaid](https://mermaid-js.github.io/mermaid/#/)

{{% grid col="1-2" y="top" %}}

```markdown
{{</* mermaid class="uk-text-center" */>}}
graph TD
  A[Hard edge] -->|Link text| B(Round edge)
  B --> C{Decision}
  C -->|One| D[Result one]
  C -->|Two| E[Result two]
{{</* /mermaid */>}}
```

{{< mermaid class="uk-text-center">}}
graph TD
  A[Hard edge] -->|Link text| B(Round edge)
  B --> C{Decision}
  C -->|One| D[Result one]
  C -->|Two| E[Result two]
{{< /mermaid >}}

{{% /grid %}}

| Options | |
|--|--|
| `class` | Additional classes on the wrapper element |

---
