##
# Wiki
#
# Copyright (c) 2012-2014 Alexander Taylor <ajtaylor@fuzyll.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
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
