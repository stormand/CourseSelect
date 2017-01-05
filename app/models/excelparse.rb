=begin
用Ruby读取Excel文件
Parseexcel是一个ruby端的perl解析excel的插件
=end

Spreadsheet::Parseexcel.parse("course.excel")
worksheet = workbook.worksheet(0)
 worksheet.each { |row|
     j = 0
     i = 0
     if row != nil
           row.each { |cell|
               if cell != nil
                         contents = cell.to_s('latin1')
                         puts "Row: #{j} Cell: #{i} #{contents}"
                       end
               i = i+1
             }
           j = j +1
           end
   }

=begin
 cell.to_s('latin1') #读取字符串
 cell.to_s('latin1') #读取float值
 cell.to_i           #读取int值
 cell.date           #读取一个时间值
 cell = row.at(3)    #读取特定值
=end

require 'parseexcel'

 #从命令行输入要打开的excel文件名
 workbook = Spreadsheet::ParseExcel.parse(ARGV[0])

 #得到第一个表单
 worksheet = workbook.worksheet(0)
 #遍历行
 worksheet.each { |row|
     j=0
     i=0
     if row != nil
           #遍历该行非空单元格
           row.each { |cell|
               if cell != nil
                        #取得单元格内容为string类型
                         contents = cell.to_s('latin1')
                         puts "Row: #{j} Cell: #{i}> #{contents}"
                       end
               i = i+1
             }
           end
   }