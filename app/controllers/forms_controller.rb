require 'json'

class FormsController < ApplicationController
  before_action :set_form, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user

  # Please see the handler for details
  before_action :form_parameter_name_redirect

  # GET /forms
  def index
    @forms = Form.all
    @workshop = Workshop.find(params[:workshop_id])
    @structure = []
    @forms.each do |form|
      @structure.push JSON.parse form.structure
    end
  end

  # GET /forms/1
  def show
  end

  # GET /forms/new
  def new
    @form = Form.by_type(form_params["type"])
    @structure = []
    @structure.push "type"=>"text", "caption"=>"Firstname", "name"=>"firstname", "class"=>"immutable_element"
    @structure.push "type"=>"text", "caption"=>"Lastname", "name"=>"lastname", "class"=>"immutable_element"
    @structure.push "type"=>"text", "caption"=>"E-Mail", "name"=>"email", "class"=>"immutable_element"
  end

  # GET /forms/1/edit
  def edit
  end

  # POST /forms
  def create
    workshop_id = form_params[:workshop_id]
    @workshop = Workshop.find(workshop_id)
    @form = Form.by_type(form_params["type"])
    @form.update_attributes(form_params)

    if @form.class.name == 'CoachForm' && @workshop != nil
      @key = SecureRandom.hex
      @workshop.update_attributes!(:coach_key => @key)
    end

    @form.workshop_id = workshop_id
    if @form.save
      flash[:success] = "Form was successfully created."
      redirect_to @form
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /forms/1
  def update
    @form = Form.find_by_id(params[:id])
    if @form.update_attributes(form_params)
      flash[:success] = "Form was successfully updated."
      redirect_to @form
    else
      render action: 'edit'
    end
  end

  # DELETE /forms/1
  def destroy
    @form.destroy
    if @form.workshop != nil
      @form.workshop.published = false
      @form.workshop.save
    end
    flash[:success] = "Form was successfully destroyed. Due to this, the corresponding Workshop is no longer published"
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_form
      @form = Form.find(params[:id])
    end

    def signed_in_user
      store_location
      unless signed_in?
        flash[:error] = "Only for Admins available! Please sign in."
        redirect_to admin_path
      end
    end

    # Only allow a trusted parameter "white list" through.
    def form_params
      params[:form]
    end

    # As it turns out, the original developers used both workshop_id and form[workshop_id]
    # when linking to the form creation/editing page.
    # This controller requires all form related parameters to be stored in the form[]
    # namespace though. So as a quick fix, we redirect to a URL where the parameters are
    # properly namespaced.
    def form_parameter_name_redirect
      return if params["workshop_id"].nil?

      redirect_to url_for({:form => {
        :workshop_id => params[:workshop_id],
        :type => params[:type]
      }})
    end
end
