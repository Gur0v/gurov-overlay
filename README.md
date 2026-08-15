# gurov-overlay

To save myself (and upstream reviewers) some back-and-forth, I decided to spin up my own overlay for the packages I use every day.

<img src="https://wiki.gentoo.org/images/4/4c/Znurt.svg" width="150" />

## How to add this overlay

The easiest way to add this repository is with `eselect repository`.

**1. Enable the overlay:**

```bash
sudo eselect repository enable gurov-overlay
```

**2. Sync the repository:**

```bash
sudo emaint sync -r gurov-overlay
```

If you don't have `eselect repository` installed:

```bash
sudo emerge app-eselect/eselect-repository
```

## About

I created this overlay to give myself more control and flexibility over the packages I maintain. It mainly contains software I use regularly that is either not available in Gentoo or GURU, or is present there but not maintained at a level that meets my needs, or where I have a specific reason to maintain my own ebuild.

Packages may be removed at any time. If something becomes actively maintained in GURU, I will usually drop my version rather than maintain duplicate ebuilds.

I may also remove packages I no longer use. If I remove something you depend on, feel free to open an issue and I will consider restoring it.
