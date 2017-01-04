=begin
Date: 2016.12.28
创建基于Importex::Base的类
使用导入excel的ruby插件 importex
gem install importex
或者使用
./script/plugin install git://github.com/ryanb/importex.git
=end

class ExcelController < ApplicationController
  def parse
  #output excel
  respond_to :html, :xlsx
  def index
    @user = User.all
    respond_with @users
  end
  end

  def creat
    @excel = Excel.new(excel_params)
    @book.excel.url = params[:file];
  end

end

