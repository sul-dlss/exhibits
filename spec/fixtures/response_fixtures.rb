module ResponseFixtures
  def zotero_api_response
    [
      {
        'data' =>
          {
            'creators': [
              {
                'firstName': 'John',
                'lastName': 'Doe'
              }
            ],
            'date': 2001,
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
            'creators': [
              {
                'firstName': 'Jane',
                'lastName': 'Doe'
              }
            ],
            'date': 2010,
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
            'creators': [
              {
                'firstName': 'Jane',
                'lastName': 'Doe'
              }
            ],
            'date': 2001,
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
            'creators': [
              {
                'firstName': 'Jane',
                'lastName': 'Doe'
              }
            ],
            'date': 2001,
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
            'creators': [
              {
                'firstName': 'Jane',
                'lastName': 'Doe'
              }
            ],
            'date': 2001,
            'tags' => [
              {
                'tag' => 'cc333dd4444'
              }
            ]
          }
      },
      {
        'data' =>
          {
            'date': 2002,
            'tags' => [
              {
                'tag' => 'cc333dd4444'
              }
            ]
          }
      },
      {
        'data' =>
          {
            'creators': [],
            'date': 1988,
            'tags' => [
              {
                'tag' => 'cc333dd4444'
              }
            ]
          }
      },
      {
        'data' =>
          {
            'creators': [
              {
                'lastName': 'The Artist'
              }
            ],
            'date': 1999,
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
