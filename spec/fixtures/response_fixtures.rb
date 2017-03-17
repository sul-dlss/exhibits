module ResponseFixtures
  def zotero_api_response
    [
      {
        'data' =>
          {
            'tags' => [
              {
                'tag' => 'ee555ff6666'
              }
            ]
          }
      },
      {
        'data' =>
          {
            'tags' => [
              {
                'tag' => 'aa111bb2222'
              }
            ]
          }
      },
      {
        'data' =>
          {
            'tags' => [
              {
                'tag' => 'cc333dd4444'
              }
            ]
          }
      }
    ]
  end
end
