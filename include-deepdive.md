<p><a target="_blank" href="https://app.eraser.io/workspace/t0RFezRkZMg5RQQ70hK1" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

What's going on with the "Include" block, how does it allows us to with keeping DRY (Don't Repeat Yourself), and what is it all about.

## What does "include" do?
Similarly to many programming languages, include attributes are executed at the pre-processing stage. The specified target placed in the include block is fetched and slapped onto the current module. This mean that all attributes will be evaluated and expanded prior to the initialization of the module.

## Why is it "DRY"?
Instead of defining the entire `locals` , `provider`  and `remote backend` placed inside `provider.hcl` again and again - we only define these setting and calls once, and using a single call from within our module (using the `include` ). 

That allows for:

- Inheritance of all desired terragrunt files and values placed in of of the module's parent folders.
- Less prone to error.
- Dynamically configure values, paths, etc.
- Define once, reuse as much as you wish.



<!--- Eraser file: https://app.eraser.io/workspace/t0RFezRkZMg5RQQ70hK1 --->