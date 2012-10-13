# A sample Guardfile
# More info at https://github.com/guard/guard#readme
# 
group :development do
  guard :minitest do
    watch(%r{^lib/(?:meaty/)?(.+)\.rb$}) do |m|
      p "test/#{m[1]}_test.rb"
    end

    watch(%r{^test/(.+)\.rb$}) do |m|
      p m[0]
    end
  end
end
