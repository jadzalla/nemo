# frozen_string_literal: true

# Parent class for nodes in the response tree
class ResponseNode < ApplicationRecord
  self.table_name = "answers"

  belongs_to :form_item, inverse_of: :answers, foreign_key: "questioning_id"
  belongs_to :response
  has_closure_tree order: "new_rank", numeric_order: true, dont_order_roots: true, dependent: :destroy

  alias c children

  def debug_tree(indent: 0)
    child_tree = sorted_children.map { |c| c.debug_tree(indent: indent + 1) }.join
    chunks = []
    chunks << " " * (indent * 2)
    chunks << new_rank.to_s.rjust(2)
    chunks << " "
    chunks << self.class.name.ljust(15)
    chunks << "(FI: #{form_item.type} #{form_item.rank})"
    chunks << " Value: #{value}" if value.present?
    "\n#{chunks.join}#{child_tree}"
  end

  def associate_response(response)
    self.response = response
    children.each do |child|
      child.associate_response(response)
    end
  end
end
