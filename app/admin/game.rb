ActiveAdmin.register Game do
  permit_params :name, :active_until, :is_paid

  actions :all, :except => [:destroy]

  index do
    column :id
    column :name
    column :sname
    column :status
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    inputs 'General' do
      input :name
      input :sname
      input(:status, as: :select, collection: [
        resource.class::STATUS_ENABLED,
        resource.class::STATUS_DISABLED,
        resource.class::STATUS_COMING_SOON
      ])
      input :order, as: :number
      input :features
    end
    actions
  end

end