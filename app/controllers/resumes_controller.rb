class ResumesController < ApplicationController
  def index
    @resumes = Resume.all
  end

  def new
    @resume = Resume.new
  end

  def create
    @resume = Resume.new(resume_params)

    if @resume.save
      redirect_to resumes_path, notice: "The resume #{@resume.name} has been uploaded."
    else
      render "new"
    end
  end

  def show
    @resume = Resume.find(params[:id])
    @resume_files = Zip::File.open(@resume.attachment.file.file)
  end

  def destroy
    @resume = Resume.find(params[:id])
    @resume.destroy
    redirect_to resumes_path, notice:  "The resume #{@resume.name} has been deleted."
  end

  def show_xml
    @xml_output = ""
    @resume = Resume.find(params[:id])
    @resume_files = Zip::File.open(@resume.attachment.file.file)
    @resume_files.entries.each do |entry|
      if entry.name == params[:name]
        @xml_output = entry.get_input_stream.read
        @entry = entry
        break
      end
    end
    if params[:xml_path].present?
      value = Nokogiri::XML(@xml_output)
      if params[:highlight] == "true"
        @highlight_content = value.xpath(params[:xml_path]).to_xml
        @highlight_content.gsub!("\n", "\r\n")
        @xml_output.gsub!(@highlight_content, "")
      else
        @xml_output = value.xpath(params[:xml_path]).to_xml
      end
    end
  end


private
  def resume_params
    params.require(:resume).permit(:name, :attachment)
  end
end
