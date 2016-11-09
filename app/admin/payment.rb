ActiveAdmin.register Payment do
  index do
    column :id
    column :type
    column 'Type' do |p|
      p.type
    end
    column 'Status' |p|
      p.status
    end
    column :created_at
    actions
  end
end