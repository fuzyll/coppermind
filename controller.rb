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

module Wiki
    # create or use existing git repository for holding notes
    system("git", "init", "./pages") unless File.exists?("./pages/.git")  # FIXME: should maybe do this in a Rakefile?
    Repository = Git.open("./pages")  # FIXME: should gracefully fail with a special error page if this doesn't work

    # create a markdown renderer to convert notes to html
    # FIXME: does Sinatra/Rack's "markdown" handler finally support this stuff now? (should double-check)
    renderer = Redcarpet::Render::HTML.new(:filter_html => true, :no_styles => true, :with_toc_data => true)
    extensions = { :no_intra_emphasis => true, :tables => true, :fenced_code_blocks => true,
                   :strikethrough => true, :space_after_headers => true, :superscript => true }
    Markdown = Redcarpet::Markdown.new(renderer, extensions)

    # FIXME: does this even need to be a class..?
    class Page
        def self.content(path)
            begin
                object = Repository.object("HEAD:#{path}.md")
            rescue Exception => e
                STDERR.puts e.message  # FIXME: DEBUG MESSAGE
                return ""
            end
            return object.contents
        end

        def self.update(path, data, message)
            # do nothing if no data was modified
            return if data == Page.content(path)

            # create subdirectories if they don't already exist
            mkdir(path)

            # write data to file
            File.open("./pages/#{path}.md", "w") do |f|
                f.write(data)
            end

            # commit changes to repository
            Dir.chdir("./pages") do
                Repository.add("#{path}.md")
            end
            Repository.commit(message)

            return
        end

        def self.move(old, new, message)
            # create subdirectories if they don't already exist
            mkdir(new)

            # move the file
            Repository.lib.mv("#{old}.md", "#{new}.md")

            # commit change to repository
            Repository.commit(message)
        end

        def self.delete(path, message)
            # delete the file
            Repository.lib.remove("#{path}.md")

            # commit change to repository
            Repository.commit(message)
        end

        def self.history(path)
            commits = []

            begin
                Repository.log.object("#{path}.md").each do |entry|
                    commit = {
                        :message => entry.message,
                        :date => entry.date.strftime("%Y-%m-%d at %H:%M:%S %Z"),
                        :author => entry.author.name,
                        :hash => entry.sha
                    }
                    commits << commit
                end
            rescue
                commits = nil
            end

            return commits
        end

        def self.diff(first, second)
            # we assume first and second are the two commit hashes to compare
            return Repository.diff(first, second).patch  # FIXME: not actually tested...
        end

    private
        def self.mkdir(path)
            if path.count('/') > 0
                dirs = "./pages/#{path.split('/')[0..-2].join}"
                FileUtils.mkpath(dirs) if !File.directory?(dirs)
            end
        end
    end


    # class implementing the web application
    class Application < Sinatra::Base
        set :public_folder, "./content"

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
