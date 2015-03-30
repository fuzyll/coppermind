(function($) {
    skel.init({
        reset: "full",
        breakpoints: {
            global: { href: "css/style.css", containers: "45em", grid: { gutters: ["2em", 0] } },
            xlarge: { media: "(max-width: 1680px)", href: "css/style-huge.css" },
            large: { media: "(max-width: 1280px)", href: "css/style-large.css", containers: "42em", grid: { gutters: ["1.5em", 0] }, viewport: { scalable: false } },
            medium: { media: "(max-width: 1024px)", href: "css/style-medium.css", containers: "85%!" },
            small: { media: "(max-width: 736px)", href: "css/style-small.css", containers: "90%!", grid: { gutters: ["1.25em", 0] } },
            xsmall: { media: "(max-width: 480px)", href: "css/style-tiny.css" }
        },
        plugins: {
            layers: {
                config: {
                    mode: "transform"
                },
                title_bar: {
                    breakpoints: "medium",
                    width: "100%",
                    height: 44,
                    position: "top-left",
                    side: "top",
                    html: "<span class=\"toggle\" data-action=\"toggleLayer\" data-args=\"side_panel\"></span><span class=\"title\" data-action=\"copyText\" data-args=\"logo\"></span>"
                },
                side_panel: {
                    breakpoints: "medium",
                    hidden: true,
                    width: { small: 275, medium: "20em" },
                    height: "100%",
                    animation: "pushX",
                    position: "top-left",
                    side: "left",
                    orientation: "vertical",
                    clickToHide: true,
                    html: "<div data-action=\"moveElement\" data-args=\"toc\"></div>"
                }
            }
        }
    });

    $(function() {
        var $body = $("body");
        var $header = $("#toc");
        var $nav = $("#nav");
        var $nav_a = $nav.find("a");
        var $wrapper = $("#wrapper");

        // header
        var ids = [];

        // set up nav items
        $nav_a
            .scrolly()
            .on("click", function(event) {
                var $this = $(this);
                var href = $this.attr('href');

                // bail if not an internal link
                if (href.charAt(0) != '#') {
                    return;
                }

                // prevent default behavior
                event.preventDefault();

                // remove active class from all links and mark them as locked (so scrollzer leaves them alone)
                $nav_a.removeClass('active').addClass('scrollzer-locked');

                // set active class on this link
                $this.addClass('active');
            })
            .each(function() {
                var $this = $(this);
                var href = $this.attr('href');
                var id;

                // Not an internal link? Bail.
                if (href.charAt(0) != '#') {
                    return;
                }

                // add to scrollzer id list
                id = href.substring(1);
                $this.attr('id', id + '-link');
                ids.push(id);
            });
    });
})(jQuery);
