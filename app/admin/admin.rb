ActiveAdmin.register User, as: 'Admin' do
  menu parent: 'Users'

  scope_to { User.admins }
end
