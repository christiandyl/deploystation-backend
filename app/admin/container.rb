ActiveAdmin.register Container do
  permit_params :name, :active_until, :is_paid
  actions :all, :except => [:destroy]
  
  config.clear_action_items!
  config.per_page = 50
  
  scope :all, default: true
  scope("Active") { |scope| scope.where("active_until > ?", Time.now.to_datetime) }
  scope("Inactive") { |scope| scope.where("active_until < ?", Time.now.to_datetime) }
  
  member_action :send_prolongation, method: :get do
    ContainerMailer.delay.container_prolongation_email(resource.id)
    redirect_to :back, notice: "Done"
  end
  
  member_action :start, method: :post do
    Sidekiq::Client.push('class' => "ApiDeploy::ContainerStartWorker", 'args' => [resource.id])
    sleep(2)
    redirect_to :back, notice: "Server will start in few seconds"
  end
  
  member_action :stop, method: :post do
    Sidekiq::Client.push('class' => "ApiDeploy::ContainerStopWorker", 'args' => [resource.id])
    sleep(2)
    redirect_to :back, notice: "Server will stop in few seconds"
  end

  member_action :remove, method: :delete do
    Container.find(resource.id).destroy_container
    sleep(2)
    redirect_to :back, notice: "Container will be deleted in the nearest time"
  end
  
  index do
    column :id
    column :name
    column :status
    column :active_until
    column :is_paid
    column "Game" do |c|
      link_to c.game.name, admin_game_path(c.game)
    end
    column "Owner" do |c|
      begin
      link_to c.user.full_name, admin_user_path(c.user)
      rescue
        ""
      end
    end
    column "Address" do |c|
      begin
        c.host.domain + ":" + c.port
      rescue
      end
    end
    actions do |c|
      str = link_to "Send prolongation", send_prolongation_admin_container_path(c), class: "edit_link member_link"

      if c.status == "online"
        str << link_to("Stop", stop_admin_container_path(c), method: :post, class: "edit_link member_link")
      else
        str << link_to("Start", start_admin_container_path(c), method: :post, class: "edit_link member_link")
      end

      str << link_to("Destroy", remove_admin_container_path(c), method: :delete, class: "edit_link member_link")
      
      str
    end
  end
  
  filter :name
  filter :game
  filter :is_paid
  filter :status, as: :select, collection: ["online", "offline"]
  filter :active_until
  filter :owner
  filter :user
  
  # scope("Active") { |scope| scope.where(is_paid: true) }

  form do |f|
    inputs 'Details' do
      input :active_until
      input :is_paid
    end
    actions
  end

end
