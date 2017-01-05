class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]

  def update
    @grade=Grade.find_by_id(params[:id])

    if (params[:grade][:grade].to_i>0 && params[:grade][:grade].to_i<=100)
      @grade.update_attributes(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "请输入0到100的整数"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end


  def excel_in

    require 'importex'
    Excel <Importex::Base
      column "Name",:required=> true
      column "class",:required=> true
      column "Grades",:type=> Integer
      column  "Date",:type=> Date
      column "Discontinued",:type=> Boolean

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

  end


  def index
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end


  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
