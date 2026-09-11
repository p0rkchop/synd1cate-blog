# Repo is public, despite an initial preference for private

We initially wanted the blog's source repo private. Giscus (the chosen comment
system) attaches comments to GitHub Discussions, which requires the hosting
repo to be public — visitors authenticate via GitHub OAuth and post directly
into that repo's Discussions tab; a private repo can't accept discussions from
arbitrary visitors. Rather than stand up a second dedicated repo just to host
discussions, we made the single blog repo public and enabled Discussions on
it, since a personal blog's source has no private/secret content anyway.

If comments are dropped later, there's no forcing reason to keep the repo
public — but flipping it back to private will break Giscus until a
replacement (or a separate public discussions repo) is wired up.
