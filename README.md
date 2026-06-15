# gurov-overlay
To save myself (and the upstream reviewers) some back-and-forth, I decided to spin up my own overlay for the packages I use every day.

<img src="https://wiki.gentoo.org/images/4/4c/Znurt.svg" width="150" />

## How to add this overlay

The easiest way to add this repository to your Gentoo system is using `eselect repository`.

**1. Enable the overlay:**
```bash
sudo eselect repository add gurov-overlay git https://github.com/Gur0v/gurov-overlay.git
```

**2. Sync the repository:**

```bash
sudo emaint sync -r gurov-overlay
```

*(Note: If you don't have `eselect repository` installed, you can get it by running `emerge app-eselect/eselect-repository`)*
