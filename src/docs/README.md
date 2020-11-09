# MuShop Docs

## Looking for the Docs?

See [https://oracle-quickstart.github.io/oci-cloudnative/](https://oracle-quickstart.github.io/oci-cloudnative/)

## Developing the Docs

Project documentation is built with [Hugo](https://gohugo.io/) and customized [UIkit](https://getuikit.com) theme.

### Setup

1. Install documentation theme:

    ```sh
    make theme
    ```

1. Install [`hugo` CLI](https://gohugo.io/getting-started/installing/):

    ```sh
    brew install hugo
    ```

### Development

In general, the content management follows all the standard features of Hugo.

- [Hugo Content Management](https://gohugo.io/content-management/)

#### Start hugo server

```sh
make dev
```

Or with `hugo`:

```sh
hugo server --buildDrafts
```

### Usage

Open [http://localhost:1313/usage](http://localhost:1313/usage)
