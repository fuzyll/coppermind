##
# Wiki
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

require "./model"

module Wiki
    # open the pages repository
    begin
        Repository = Git.open("./pages")
    rescue
        Repository = nil
    end

    # create a custom markdown renderer with non-standard options turned on
    renderer = Redcarpet::Render::HTML.new(:filter_html => true, :no_styles => true, :hard_wrap => true)
    extensions = { :no_intra_emphasis => true, :tables => true, :fenced_code_blocks => true,
                   :strikethrough => true, :space_after_headers => true, :superscript => true }
    Markdown = Redcarpet::Markdown.new(renderer, extensions)

    class Application < Sinatra::Base
        # parse and set settings
        begin
            File.open("./settings.json", "r") do |file|
                JSON.parse(file.read()).each do |k,v|
                    set k, v
                end
            end
        rescue Exception => e
            abort "Could not parse settings file because: #{e.message}"
        end

        before do
            return erb :error if Repository == nil
        end

        not_found do
            return erb :missing
        end

        get "/?" do
            redirect to "/main"
        end

        get "/*/edit/?" do
            @path = params[:splat].join("/")
            @page = Page.content(@path)
            return erb :edit
        end

        post "/*/edit/?" do
            @path = params[:splat].join("/")
            @content = params[:content]
            @summary = params[:summary]  # FIXME: should bail out if summary or content doesn't exist
            Page.update(@path, @content, @summary)

            # send the user to their new page
            redirect to "/#{@path}"
        end

        get "/*/move/?" do
            @path = params[:splat].join("/")
            return erb :move
        end

        post "/*/move/?" do
            @path = params[:splat].join("/")
            @new_path = params[:path]
            @summary = params[:summary]  # FIXME: should bail out if new_path or summary doesn't exist
            Page.move(@path, @new_path, @summary)
            redirect to "/#{@new_path}"
        end

        get "/*/delete/?" do
            @path = params[:splat].join("/")
            return erb :delete
        end

        post "/*/delete/?" do
            @path = params[:splat].join("/")
            @summary = params[:summary]  # FIXME: should bail out if summary doesn't exist
            Page.delete(@path, @summary)
            redirect to "/#{@path}"
        end

        get "/*/history/?" do
            @path = params[:splat].join("/")
            @history = Page.history(@path)
            return erb :history
        end

        get "/*/?" do
            # get the requested page
            @path = params[:splat].join("/")
            @page = Markdown.render(Page.content(@path))

            # redirect to the edit interface if the page wasn't found or is blank
            if @page == ""
                redirect to "#{@path}/edit"
            else
                return erb :show
            end
        end
    end
end
