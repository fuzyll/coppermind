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

require "./model"
require "./renderer"

module Coppermind
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

        helpers do
            # function to create table of contents items from markdown
            def create_toc(markdown)
                toc = []
                markdown.lines.each do |line|
                    # find first and second level headers (actually h2 and h3 - h1 is special and used as page header)
                    # matched text will be placed in the "text" key
                    # the \s* here gets around errant whitespace and \r\n line-endings (which will cause $ to not match)
                    header = /^\s*\#\# (?<text>.*) \#\#\s*$/.match(line)
                    level = "first"
                    if not header
                        header = /^\s*\#\#\# (?<text>.*) \#\#\#\s*$/.match(line)
                        level = "second"
                        if not header
                            next
                        end
                    end
                
                    # if we were successful in finding a header, add an entry to our table of contents
                    # link has to be normalized to match what redcarpet will do with :with_toc_data renderer option
                    # FIXME: normalization here doesn't actually match in all cases...
                    entry = {
                        :name => header["text"],
                        :link => header["text"].downcase.gsub(/[^0-9a-z]/i, ""),
                        :class => level
                    }
                    toc << entry
                end
                return toc
            end
        end

        before do
            @toc = []
            return erb :error if Repository == nil
        end

        not_found do
            return erb :missing
        end

        get "/?" do
            redirect to "/read/root"
        end

        get "/read/?" do
            redirect to "/read/root"
        end

        get "/read/*/?" do
            # get the requested page
            @path = params[:splat].join("/")
            @page = Markdown.render(Page.content(@path))
            @toc = create_toc(Page.content(@path))

            # redirect to the edit interface if the page wasn't found or is blank
            if @page == "" or not @page
                redirect to "edit/#{@path}"
            else
                return erb :read
            end
        end

        get "/edit/*/?" do
            @path = params[:splat].join("/")
            @page = Page.content(@path)
            return erb :edit
        end

        post "/edit/*/?" do
            @path = params[:splat].join("/")
            @content = params[:content]
            @summary = params[:summary]  # FIXME: should bail out if summary or content doesn't exist
            Page.update(@path, @content, @summary)
            redirect to "/read/#{@path}"
        end

        get "/move/*/?" do
            @path = params[:splat].join("/")
            return erb :move
        end

        post "/move/*/?" do
            @path = params[:splat].join("/")
            @new_path = params[:path]
            @summary = params[:summary]  # FIXME: should bail out if new_path or summary doesn't exist
            Page.move(@path, @new_path, @summary)
            redirect to "/read/#{@new_path}"
        end

        get "/delete/*/?" do
            @path = params[:splat].join("/")
            return erb :delete
        end

        post "/delete/*/?" do
            @path = params[:splat].join("/")
            @summary = params[:summary]  # FIXME: should bail out if summary doesn't exist
            Page.delete(@path, @summary)
            redirect to "/read/#{@path}"
        end

        get "/history/*/?" do
            @path = params[:splat].join("/")
            @history = Page.history(@path)  # FIXME: currently broken because of the git gem...
            return erb :history
        end

        get "/list/?" do
            @list = Dir["./pages/**/*.md"]
            return erb :list
        end

        get "/activity/?" do
            @history = Page.history("/")  # FIXME: this will break once I fix the problems with history
            return erb :history
        end
    end
end
