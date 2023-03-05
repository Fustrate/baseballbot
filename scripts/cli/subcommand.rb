# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

class Subcommand < Thor
  def self.banner(command, _namespace = nil, _subcommand = nil)
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  def self.subcommand_prefix
    name.gsub(/.*::/, '').gsub(/^[A-Z]/, &:downcase).gsub(/[A-Z]/) { "_#{_1[0].downcase}" }
  end

  protected

  def parse_array(input) = input&.split(/[,+]/) || []
end
