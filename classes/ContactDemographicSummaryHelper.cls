/**
 * @description Helper class for generating AI-powered demographic summaries for contacts
 * @author Salesforce Agentforce Implementation
 * @date 2024
 */
public with sharing class ContactDemographicSummaryHelper {
    
    /**
     * @description Generates demographic summary for a contact using Agentforce
     * @param contactId The ID of the contact to generate summary for
     * @return String The generated demographic summary
     */
    public static String generateDemographicSummary(Id contactId) {
        try {
            // Query contact with all relevant demographic fields
            Contact contact = [
                SELECT Id, FirstName, LastName, Title, Email, Phone, 
                       MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                       Department, LeadSource, Birthdate, Account.Name, Account.Industry
                FROM Contact 
                WHERE Id = :contactId 
                LIMIT 1
            ];
            
            // Build demographic summary prompt
            String promptText = buildDemographicPrompt(contact);
            
            // Use Einstein GPT to generate summary (placeholder for actual implementation)
            String summary = generateAISummary(promptText, contact);
            
            return summary;
            
        } catch (Exception e) {
            System.debug('Error generating demographic summary: ' + e.getMessage());
            return 'Unable to generate demographic summary at this time.';
        }
    }
    
    /**
     * @description Builds the AI prompt for demographic summary generation
     * @param contact The contact record to build prompt for
     * @return String The formatted prompt text
     */
    private static String buildDemographicPrompt(Contact contact) {
        String prompt = 'Generate a professional demographic summary for the following contact:\n\n';
        
        prompt += 'Personal Information:\n';
        prompt += '- Name: ' + (contact.FirstName != null ? contact.FirstName + ' ' : '') + 
                  (contact.LastName != null ? contact.LastName : '') + '\n';
        prompt += '- Title: ' + (contact.Title != null ? contact.Title : 'Not specified') + '\n';
        prompt += '- Department: ' + (contact.Department != null ? contact.Department : 'Not specified') + '\n';
        
        prompt += '\nCompany Information:\n';
        prompt += '- Company: ' + (contact.Account?.Name != null ? contact.Account.Name : 'Not specified') + '\n';
        prompt += '- Industry: ' + (contact.Account?.Industry != null ? contact.Account.Industry : 'Not specified') + '\n';
        
        prompt += '\nContact Information:\n';
        prompt += '- Email: ' + (contact.Email != null ? contact.Email : 'Not provided') + '\n';
        prompt += '- Phone: ' + (contact.Phone != null ? contact.Phone : 'Not provided') + '\n';
        
        prompt += '\nGeographic Information:\n';
        String location = '';
        if (contact.MailingCity != null) location += contact.MailingCity;
        if (contact.MailingState != null) location += (location.length() > 0 ? ', ' : '') + contact.MailingState;
        if (contact.MailingCountry != null) location += (location.length() > 0 ? ', ' : '') + contact.MailingCountry;
        prompt += '- Location: ' + (location.length() > 0 ? location : 'Not specified') + '\n';
        
        prompt += '\nLead Information:\n';
        prompt += '- Lead Source: ' + (contact.LeadSource != null ? contact.LeadSource : 'Not specified') + '\n';
        
        prompt += '\nPlease create a 2-3 paragraph professional summary focusing on demographic and business characteristics that would be valuable for sales, marketing, and customer service teams.';
        
        return prompt;
    }
    
    /**
     * @description Generates AI summary using Einstein GPT (placeholder implementation)
     * @param promptText The prompt to send to AI
     * @param contact The contact record for context
     * @return String The generated summary
     */
    private static String generateAISummary(String promptText, Contact contact) {
        // Placeholder implementation - in real Agentforce implementation,
        // this would call Einstein GPT API or use ConnectApi.EinsteinGPT
        
        String summary = '';
        
        // Build a template summary based on available data
        summary += contact.FirstName + ' ' + contact.LastName + ' is ';
        
        if (contact.Title != null) {
            summary += 'a ' + contact.Title + ' ';
        }
        
        if (contact.Account?.Name != null) {
            summary += 'at ' + contact.Account.Name + '. ';
        }
        
        if (contact.MailingCity != null && contact.MailingState != null) {
            summary += 'Based in ' + contact.MailingCity + ', ' + contact.MailingState + ', ';
        }
        
        summary += 'this contact represents ';
        
        if (contact.Account?.Industry != null) {
            summary += 'the ' + contact.Account.Industry + ' sector ';
        }
        
        summary += 'and was acquired through ' + (contact.LeadSource != null ? contact.LeadSource : 'unknown') + ' lead source. ';
        
        summary += 'The demographic profile suggests a professional contact suitable for business-to-business engagement ';
        summary += 'with potential for ongoing commercial relationship development.';
        
        return summary;
    }
    
    /**
     * @description Batch updates demographic summaries for multiple contacts
     * @param contactIds Set of contact IDs to update
     */
    public static void updateDemographicSummaries(Set<Id> contactIds) {
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Id contactId : contactIds) {
            String summary = generateDemographicSummary(contactId);
            contactsToUpdate.add(new Contact(
                Id = contactId,
                Demographic_Summary__c = summary
            ));
        }
        
        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating contact demographic summaries: ' + e.getMessage());
            }
        }
    }
}