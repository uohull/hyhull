module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the search page/
      '/'
    when /logout/
      destroy_user_session_path
    when /the base search page/
      '/catalog?q=&search_field=search&action=index&controller=catalog&commit=search'
    when /the document page for id (.+)/ 
      catalog_path($1)
    when /the edit page for id (.+)/ 
      edit_catalog_path($1)
    when /the catalog index page/
      catalog_index_path
    when /the edit document page for (.*)$/i
      edit_catalog_path($1, :viewing_context=>'edit')
    when /the show document page for (.*)$/i
      catalog_path($1)
    when /the file list page for (.*)$/i
      asset_file_assets_path($1)
    when /the file asset (.*) with (.*) as its container$/i
      asset_file_asset_path($2, $1)
    when /the file asset (.*)$/i
      file_asset_path($1)
      
    when /the (\d+)(?:st|nd|rd|th) (person|organization|conference) entry in (.*)$/i
      asset_contributor_path($3, $2, $1.to_i-1)
    when /the ([^ ]+) datastream content page for (.*)$/i
      datastream_content_path($2,$1)
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)