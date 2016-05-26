class PointDeVuesController < ApplicationController
  before_action :authenticate_animateur!, except: [:index, :show, :last_actu, :new]

	def index
		@point_de_vues = PointDeVue.order(updated_at: :desc)
	end

	def show
    @point_de_vue = PointDeVue.find(params[:id])
  end
  
  def new
  	@point_de_vue = PointDeVue.new
    villes = Ville.order(:name)

    @coms = []
    @coms << ["","","commune 0"]
    villes.each do |ville|
      com = []
      com << ville.name
      com << ville.id
      com << {class: "commune #{ville.codepostal.id}"}
      @coms << com
    end

    @codepostals = Codepostal.order(:codepostal)
  end

  def create
    point_de_vue = PointDeVue.new(point_de_vue_params)
    point_de_vue.contributeur_id = current_contributeur.id
    if point_de_vue.save
      Animateur.all.each do |animateur|
        AnimateurMailer.nouveau_point_de_vue(animateur, point_de_vue).deliver_now
      end
      redirect_to point_de_vues_path, method: :get
    else
      render 'new'
    end
  end

  def edit
    villes = Ville.order(:name)

    @coms = []
    @coms << ["","","commune 0"]
    villes.each do |ville|
      com = []
      com << ville.name
      com << ville.id
      com << {class: "commune #{ville.codepostal.id}"}
      @coms << com
    end

    @codepostals = Codepostal.order(:codepostal)
    @point_de_vue = PointDeVue.find(params[:id])
  end


  def destroy
    point_de_vue = PointDeVue.find(params[:id])
    point_de_vue.destroy
    redirect_to animation_path, method: :get

  end

  def jadhere
    @point_de_vue = PointDeVue.find(params[:id])
    if @point_de_vue.jadhere_by? current_contributeur
      redirect_to @point_de_vue
    else
      @point_de_vue.jadheres.create(contributeur_id: current_contributeur.id)
      redirect_to @point_de_vue
    end
  end

  def unjadhere
    @point_de_vue = PointDeVue.find(params[:id])
    if @point_de_vue.jadhere_by? current_contributeur
      @point_de_vue.jadheres.select { |jadhere| jadhere.contributeur_id == current_contributeur.id }.first.destroy
    end
    redirect_to @point_de_vue
  end
  
  private

  def point_de_vue_params
    params.require(:point_de_vue)
    .permit(:image,
            :codepostal_id,
            :ville_id,
            :description)
  end

end
