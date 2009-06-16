class UsersController < ApplicationController
  layout 'simple_with_help'
    
  # Protect these actions behind an admin login
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      logger.info('success')
      redirect_back_or_default('/')
      flash[:notice] = "A regisztráció sikerült! Az aktivációs levél úton van!"
    else
      logger.info('bad news')
      flash[:notice]  = "Sajnos valami nincs rendben. A regisztráció nem sikerült."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Az aktiváció sikeres volt!"
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "Az aktivációs kód hiányzik. Nézd meg a levélben!"
      redirect_back_or_default('/')
    else 
      flash[:error]  = "Nem találom az aktiválandó felhasználót. Ellenőrizd az email címet! (Vagy már aktiváltál?)"
      redirect_back_or_default('/')
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_user
    @user = User.find(params[:id])
  end
end
