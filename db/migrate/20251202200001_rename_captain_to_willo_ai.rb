class RenameCaptainToWilloAi < ActiveRecord::Migration[7.1]
  def change
    # Rename all Captain tables to Willo AI
    rename_table :captain_assistants, :willo_ai_assistants
    rename_table :captain_assistant_responses, :willo_ai_responses
    rename_table :captain_documents, :willo_ai_documents
    rename_table :captain_inboxes, :willo_ai_inboxes
    rename_table :captain_scenarios, :willo_ai_scenarios
    rename_table :captain_custom_tools, :willo_ai_custom_tools

    # Rename indexes to match new table names
    rename_index :willo_ai_assistants, 'index_captain_assistants_on_account_id', 'index_willo_ai_assistants_on_account_id'

    rename_index :willo_ai_responses, 'index_captain_assistant_responses_on_account_id', 'index_willo_ai_responses_on_account_id'
    rename_index :willo_ai_responses, 'index_captain_assistant_responses_on_assistant_id', 'index_willo_ai_responses_on_assistant_id'
    rename_index :willo_ai_responses, 'index_captain_assistant_responses_on_status', 'index_willo_ai_responses_on_status'

    rename_index :willo_ai_documents, 'index_captain_documents_on_account_id', 'index_willo_ai_documents_on_account_id'
    rename_index :willo_ai_documents, 'index_captain_documents_on_assistant_id', 'index_willo_ai_documents_on_assistant_id'
    rename_index :willo_ai_documents, 'index_captain_documents_on_external_link', 'index_willo_ai_documents_on_external_link'
    rename_index :willo_ai_documents, 'index_captain_documents_on_status', 'index_willo_ai_documents_on_status'

    # Note: willo_ai_inboxes uses captain_assistant_id column (from original migration)
    # The indexes keep their original names as they reference the original column names

    rename_index :willo_ai_scenarios, 'index_captain_scenarios_on_account_id', 'index_willo_ai_scenarios_on_account_id'
    rename_index :willo_ai_scenarios, 'index_captain_scenarios_on_assistant_id', 'index_willo_ai_scenarios_on_assistant_id'

    # Note: custom_tools only has account_id, not assistant_id
    rename_index :willo_ai_custom_tools, 'index_captain_custom_tools_on_account_id', 'index_willo_ai_custom_tools_on_account_id'
  end
end
