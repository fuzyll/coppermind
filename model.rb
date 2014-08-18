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
                dirs = "./pages/#{path.split("/")[0..-2].join("/")}"
                FileUtils.mkpath(dirs) if !File.directory?(dirs)
            end
        end
    end
end
