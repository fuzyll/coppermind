##
# Coppermind
#
# Copyright (c) 2012-2015 Alexander Taylor <ajtaylor@fuzyll.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
# IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##

module Coppermind
    class CustomRenderer < Redcarpet::Render::HTML
        def link(link, title, content)
            if link.include?("http://") or link.include?("https://")
                # leave external links alone
                return "<a href=\"#{link}\">#{content}</a>"
            else
                # patch internal links to have "read/" before the page name by default
                return "<a href=\"read/#{link}\">#{content}</a>"
            end
        end
    end

    # create a new renderer and parser with our options and extensions turned on
    renderer = CustomRenderer.new(:escape_html => true, :no_styles => true,
                                  :hard_wrap => true, :with_toc_data => true)
    extensions = { :no_intra_emphasis => true, :tables => true, :fenced_code_blocks => true,
                   :strikethrough => true, :space_after_headers => true, :superscript => true }
    Markdown = Redcarpet::Markdown.new(renderer, extensions)
end
