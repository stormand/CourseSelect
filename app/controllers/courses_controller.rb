class CoursesController < ApplicationController


  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]
  before_action :logged_in, only: [:index]


  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open:true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open:false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def excel
    @course= current_user.teaching_courses
  end

  def excel_in


    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => " 导入成功"}
    else
      flash={:warning => "导入失败"}
    end
    redirect_to excel_courses_path, flash: flash

  end

  #-------------------------for students----------------------

  def list
    @course=Course.all
    @course_open=Course.where("open = ?", true)-current_user.courses
    @course_close=@course-@course_open
    @course_display=@course
    @theparams=params
    @credit_isdegree, @credit_nodegree=cal_degree
  end
  
  def classtable
    @course=current_user.courses
  end

  def credit#add credit method

    @course_isdegree=current_user.courses.where("degree= ?", true)
    @course_nodegree=current_user.courses.where("degree= ?", false)
    @credit_isdegree, @credit_nodegree=cal_degree

  end

  def isdegree #add isdegree method
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(degree: true)
    redirect_to courses_path,flash: {:success=> "已经成功将 #{@course.name} 选为学位课"}
  end

  def nodegree #add nodegree method
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(degree: false)
    redirect_to courses_path,flash: {:success=> "已经成功将 #{@course.name} 选为非学位课"}
  end


  def select
    @allcourse=current_user.courses
    @course=Course.find_by_id(params[:id])

    @allcourse.each do |k|
      if(k.course_week.nil?||@course.course_week.nil?)
        next
      else
        week1 = (@course.course_week[0,1].to_i..@course.course_week[3,@course.course_week.length-1].to_i).to_a
        week2 = (k.course_week[0,1].to_i..k.course_week[3,k.course_week.length-1].to_i).to_a
        time1 = (@course.course_time[3].to_i..@course.course_time[5,@course.course_time.length-1].to_i).to_a
        time2 = (k.course_time[3].to_i..k.course_time[5,k.course_time.length-1].to_i).to_a
        weekn1=@course.course_time[2]
        weekn2=k.course_time[2]
      
        if (week1 & week2)!=[] && (time1 & time2)!=[] && weekn1==weekn2
          flash={:sucess => "选课时间冲突: #{@course.name}"}
          redirect_to list_courses_path, flash: flash
          return
        end
      end
   end

    if !@course.limit_num.nil? && @course.limit_num!=0
      if(@course.student_num < @course.limit_num)
        current_user.courses<<@course
        @course.student_num+=1
        @course.update_attributes(:student_num=>@course.student_num)
        flash={:success => "成功选择课程: #{@course.name}"}
        redirect_to courses_path, flash: flash
      else
        flash={:danger => "选课人数已满: #{@course.name}"}
        @course=Course.all
        @course_open=Course.where(:open=>true)
        @course_open=@course_open-current_user.courses
        redirect_to list_courses_path, flash: flash
      end
    else
       current_user.courses<<@course
        @course.student_num+=1
        @course.update_attributes(:student_num=>@course.student_num)
        flash={:success => "成功选择课程: #{@course.name}"}
        redirect_to courses_path, flash: flash
    end     
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.student_num-=1
    @course.update_attributes(:student_num=>@course.student_num)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def excel_out
    @course=Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => " 导出成功"}
    else
      flash={:warning => "导出失败"}
    end
    redirect_to excel_courses_path, flash: flash
  end

  def show
    @course = Course.find(params[:id])
  end
  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
    @credit_isdegree, @credit_nodegree=cal_degree
  end

  def cal_degree
    @credit_isdegree=0
    @credit_nodegree=0
    current_user.courses.each do |course|
      if course.degree
        @credit_isdegree=@credit_isdegree + course.credit.sub(/\d+\// , "").to_i
      else
        @credit_nodegree=@credit_nodegree + course.credit.sub(/\d+\// , "").to_i
      end
    end
    return @credit_isdegree, @credit_nodegree
  end


  def detail
    @course=Course.find_by_id(params[:id])
  end

  def search
    temp="%"+params[:name]+"%"
    @course=Course.all
    @course_open=Course.where("name like ? AND open =?", temp ,true)
    @course_close=Course.where("name like ? AND open =?", temp ,false)
    @course_display=Course.where("name like ? ", temp)

    if params[:teaching_type]!=""
        @course_open=@course_open.where("teaching_type =?", params[:teaching_type])
        @course_close=@course_close.where("teaching_type =?", params[:teaching_type])
        @course_display=@course_display.where("teaching_type =?", params[:teaching_type])
    end
    if params[:course_type]!=""
      @course_open=@course_open.where("course_type =?", params[:course_type])
      @course_close=@course_close.where("course_type =?", params[:course_type])
      @course_display=@course_display.where("course_type =?", params[:course_type])
    end
    if params[:credit]!=""
      @course_open=@course_open.where("credit =?", params[:credit])
      @course_close=@course_close.where("credit =?", params[:credit])
      @course_display=@course_display.where("credit =?", params[:credit])
    end
    if params[:exam_type]!=""
      @course_open=@course_open.where("exam_type =?", params[:exam_type])
      @course_close=@course_close.where("exam_type =?", params[:exam_type])
      @course_display=@course_display.where("exam_type =?", params[:exam_type])
    end

    @course_display=@course_display
    @course_open=@course_open-current_user.courses
    @course_close=@course_close-current_user.courses


    @theparams=params
    render 'list'
  end

  def refresh_search
    @course=Course.all
    @course_open=Course.where("open = ?", true)-current_user.courses
    @course_close=@course-@course_open
    @course_display=@course
    @theparams=params
    render 'list'
  end

  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end


  def course_params
    params.require(:course).permit(:course_code, :excel, :avatar, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week, :course_introduction)
  end
end
