class GamePluginsCollection < Array
  def self.plugins_for_container(container)
    cname = "game_plugins/#{container.game.sname}".classify.constantize
    
    list = cname.default_plugins.map do |hs|
      hs[:container] = container
      cname.new(hs)
    end
    
    return new(list)
  end
  
  def all
    select { |p| p.visible == true }
  end
  
  def enabled
    ls = []
    
    (select { |p| p.enabled? }).each do |p|
      ls << p
      unless p.dependencies.blank?
        p.dependencies.each do |dname|
          dp = find { |dp| dp.name == dname }
          dp.status = true
          if (ls.find { |sp| sp.id == dp.id }).nil?
            ls << dp
          end
        end
      end
    end
    
    return ls
  end
  
  def find_by_id(id)
    find { |p| p.id == id } or raise ActiveRecord::RecordNotFound
  end
end
