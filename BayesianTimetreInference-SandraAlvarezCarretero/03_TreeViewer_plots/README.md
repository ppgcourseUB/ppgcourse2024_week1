
# Plotting with `TreeViewer`

We will use `TreeViewer` ([Bianchini and Sánchez-Baracaldo, 2024](https://doi.org/10.1002/ece3.10873)) to plot the distributions that we have gotten for our analysis with the aim to provide a visual comparison. If there is time, I shall do a demo so that you can see how to load the various modules [following the tutorial on the `TreeViewer` Gitub Wiki page](https://github.com/arklumpus/TreeViewer/wiki/Plotting-multiple-age-distributions) -- the guidelines are very clear and easy to follow, hence there is no need to rewrite them here :)

I have provided you with [example `tbi` files](tbi_files) (i.e., `TreeViewer` files that contain the tree topology together with all the modules, attachments, attributes, and other transformations carried out to design the figure that displays our timetrees) for the alignment with first and second positions. The advantage of having `tbi` files is that you can open them in `TreeViewer` and keep the modules and attributes that are responsible for the main design of the figure. Then, you just need to add the new input files that you will use to draw the distributions on every node generated with other models, replace the old distributions in modules/attributes... And you are ready to go!

You can also find the [exported PDF files inside the `figs` directory](figs). Please note that all images have been retrieved from [Wikimedia Commons](https://commons.wikimedia.org/wiki/Main_Page) and have Creative Commons licenses.

> **EXERCISE**

Open the `tbi` files on `TreeViewer` and try to reproduce the same plots but now with the other two alignments!
