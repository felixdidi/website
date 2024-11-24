function highlight() {
            document.body.innerHTML =
                document.body.innerHTML
                .replace(/Dietrich,\sF./g, "<b>Dietrich,&nbspF.</b>");
        }

highlight()
