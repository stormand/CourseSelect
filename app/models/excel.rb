=begin
Date: 2016.12.28
创建基于Importex::Base的类
使用导入excel的ruby插件 importex
gem install importex
或者使用
./script/plugin install git://github.com/ryanb/importex.git
=end


require 'importex'
class Excel <Importex::Base
  column "Name",:required=> true
  column "class",:required=> true
  column "Grades",:type=> Integer
  column  "Date",:type=> Date
  column "Discontinued",:type=> Boolean
end

#导入excel文件
Excel.import("course.excel")

#使用导入数据
#all代表所有的数据，各个字段作为hash
excel = Excel.all
excel.first["Discontinued"] # => false

#数据验证和容错处理
#当excel的数据格式不能处理的时候，或者数据格式不符合时
begin
  Excel.import()
rescue Importex::ImportError => e
  puts e.message
end


#允许导入的字段指向Ruby对象，
# 例如，下面的例子，可以增加一个字段表示上面导入Product的类型情况
class Category < ActiveRecord::Base
  def self.importex_value(str)
    find_by_name!(str)
  rescue ActiveRecord::RecordNotFound
    raise Importex::InvalidCell, "No category with that name."
  end
end

class Product < Importex::Base
  column "Category", :type => Category
end