module ImpliedPublication
  def self.relevant_relationships
    [:subject, :linked_agents]
  end

  def is_published_by_implication?
    self.class.relationship_dependencies.any? {|relationship_name, relationship_dependency|
      next unless ImpliedPublication::relevant_relationships.include? relationship_name
      relationship_dependency.any? {|related_class|
        next unless related_class.columns.include?(:publish)
        relationship_class = related_class.find_relationship(relationship_name, true)
        reference_columns = relationship_class.reference_columns_for(self.class)
        referrer_columns = relationship_class.reference_columns_for(related_class)

        referrer_columns.any? {|referrer_column|
          reference_columns.any? {|reference_column|
            relationship_class.join(related_class, :id => referrer_column).
            filter(:publish => 1).
            filter(reference_column => self.id).
            any?
          }
        }
      }
    }
  end
end
