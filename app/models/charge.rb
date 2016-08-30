class Charge < ActiveRecord::Base
  include ApiExtension

  attr_accessor :details

  default_scope { order('charges.created_at DESC') }

  #############################################################
  #### Accessors
  #############################################################

  store_accessor :metadata, :container_id, :comment

  #############################################################
  #### Relations
  #############################################################

  belongs_to :user

  #############################################################
  #### Validations
  #############################################################

  validates :amount, presence: true

  #############################################################
  #### Callbacks setup
  #############################################################



  #############################################################
  #### API attributes
  #############################################################

  def api_attributes(layers)
    h = {
      id: id,
      user_id: user_id,
      container_id: container_id,
      amount: amount,
      details: details,
      created_at: created_at,
    }

    h
  end

  #############################################################
  #### Static methods
  #############################################################

  #############################################################
  #### Actions
  #############################################################

  #############################################################
  #### Helpers
  #############################################################

  def container_id
    super.to_i rescue nil
  end

  def self.types
    [
      { id: 1, name: 'container_charge', details: 'Container charge' }
      { id: 2, name: 'container_creation_charge', details: 'Container creation charge' }
    ]
  end

  def details
    type = self.class.types.find { |t| t[:id] == type_id } || {}
    type[:details]
  end

  def type=(name)
    name = name.to_s
    type = self.class.types.find { |t| t[:name] == name }
    self.type_id = type[:id] if type
  end
end
