module OrganizationReorganizer

  def reorganize_organization(manifest)
    modules = []
    return modules unless manifest

    manifest.css('organizations organization > item').each do |item|
      mod = {items: []}
      mod[:migration_id] = item['identifier']
      add_child_items(item, mod)
      modules << mod
    end
    modules
  end

  def add_child_items(parent_item, mod)
    parent_item.children.each do |item|
      if item.name == 'title'
        mod[:title] = item.text
      else
        if item = process_item(item)
          mod[:items] << item
        end
      end
    end
  end

  def process_item(item_node)
    mod_item = nil
    res = @resources[item_node['identifierref']]
    return mod_item if res.nil?
    case res[:material_type]
      when 'contentmodule'
      when 'content'
        mod_item = {
          type: 'linked_resource',
          item_migration_id: item_node['identifier'],
          linked_resource_id: item_node['identifierref'],
          linked_resource_title: get_node_val(item_node, 'title'),
          linked_resource_type: 'wikipage'
        }
      when 'contentlink'
        # This needs to parse the special href that's there and get the wacky hash ID out, it also needs
        # to setup the linked_resource_type to be correct for the D2l type

    end
    mod_item
  end

end