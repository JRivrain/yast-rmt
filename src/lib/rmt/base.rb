# Copyright (c) 2018 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
#  Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require 'yaml'

module RMT
end

class RMT::Base < Yast::Client
  include Yast::UIShortcuts
  include Yast::Logger
  include Yast::I18n

  CONFIG_FILENAME = '/etc/rmt.conf'.freeze

  def self.read_config_file
    begin
      data = Yast::SCR.Read(Yast.path('.target.string'), CONFIG_FILENAME)
      config = YAML.safe_load(data)
    rescue StandardError => e
      log.warn 'Reading config file failed: ' + e.to_s
    end

    config ||= {}
    config['scc'] ||= {}
    config['scc']['username'] ||= ''
    config['scc']['password'] ||= ''

    config['database'] ||= {}
    config['database']['database'] ||= 'rmt'
    config['database']['username'] ||= 'rmt'
    config['database']['password'] ||= ''
    config['database']['hostname'] ||= 'localhost'

    config
  end

  def self.write_config_file(config)
    if Yast::SCR.Write(Yast.path('.target.string'), CONFIG_FILENAME, YAML.dump(config))
      Yast::Popup.Message('Configuration written successfully')
    else
      Report.Error('Writing configuration file failed')
    end

  end

  # Runs a command and returns the exit code
  def run_command(command, *params)
    params = params.map { |p| String.Quote(p) }

    SCR.Execute(
        path('.target.bash'),
        Builtins.sformat(command, *params)
    )
  end
end
