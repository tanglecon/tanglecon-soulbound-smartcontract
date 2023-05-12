// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error FunctionNotSupported();


/*                                                                                                  
                                                  GYJ??J5G                                          
                                                 P7777777?G                                         
                                                G?77777777P                                         
                 GGGGGG                   GP5YJJJ5Y77777???5G                                       
             PYJ?77777??Y5G          GP5YJJJ5PG    GP7YPG GYJ?YP                                    
           5?77777777777777YG   GPYJJJY5PG           !Y      G5J?J5G                                
         G?77777777777777777?YJJJY5GG                7J          PYJ?55JJYP                         
        G?777777777777777777?75                      ??             GJ7777?G                        
        P777777777777777777???Y                      J?              Y7??7J                         
        P777777777777777777??7Y                      J7             ?7G  P7J                        
         ?777777777777777?????P                      Y!           P!Y      Y75                      
         GJ777777777777???????P                      5~          J7P        G7?G                    
           5J7777777???????YGPJ?J5G                  P~        P7J            Y75                   
             G??J?????JJYPG     PY?JYP               P~       J7P              G??G                 
             P~G GGGGG             G5J?JPG           G~G    P7J                  57Y GPPPPGG        
            G~P                       GPY?J5G        G^G   Y!5                    G7??77777?YG      
            !Y                            GYJ?YP      ~P G7?                     G?7777777777?5     
           7J                                G5J?J5G  ~P5!5                  GGGG?77777777777??G    
          ?7                                     PY?JJ77!YGPP5555YYYYYJJJJJJJJJJY?7777777777???G    
         Y!                                       #G?7777?YYY555PPPPGGGGGG       G?77777777???5     
        5~G                                     G5J?Y5YY5G                      GY7YJ?77???JYG      
       G~P                                    5J?YP                           GY7YG  P~PPGG         
    GPP!Y                                  PJ?JP                            GJ7Y     J7             
  5?7777?5                    GPYJJJJYPGPJ?JP                             PJ75       ~P             
 P77777777YGGGG              Y?77777777?75                              P??5        Y!              
 P7777777?YYJJJJJJJJYYY555PPJ77777777777?Y                            P??P          !5              
  PY???J??       GGGGPP555YY777777777777??G                         5??P           P~               
     GG GJ7P                J7777777777??Y                        57JG             7J               
          P7?G               Y?7777777??75                     GY7JG              G^G               
            57Y                ?7YJJYYPGPJ?YG                GY7YG                J7                
             GJ75             P~G         GY?JP            GJ7Y                   ~P                
               P??P           ~5             5??5        PJ?5                 G5YJ!YP               
                 57JG        7?                GJ?YGGPPP??P                  57777777JG             
                   Y75      Y!                   GY77777JPP55555YYYYYYYJJJJJJ777777777P             
                    G?7P   P~G                    G?777?Y555555PPPPPPGGGGGGG P777777?Y              
                      P7JGG!Y                       !JPG                    57YP555PG               
                        7777?P                     P~                     P??G                      
                       G?77775                     7J                   GJ7P                        
                        GP?7G                     G^G                  Y7Y                          
                         #P~                      ??#                57Y                            
                        P55!Y555555555555555555555!Y5555555555555555J!Y55G                          
                       P7777777777777777777777777777777777777777777777777?G                         
                      G?77777777777777777777777777777777777777777777777777Y                         
                      Y7777777777777777777777777777777777777777777777777777P                        
                     G77777777777777777777777777777777777777777777777777777J                        
                     Y7777777777777777777777777777777777777777777777777777775                       
                     555555555555555555555555555555555555555555555555555555YP                        

 * @notice This is an ERC1155 NFT contract with modification to remove transferability.
 * Ultimately turning it into a "Soulbound Token" to award key attendees, personalities or supporters from the TangleCon. 
 */

contract TangleConAwards is ERC1155, Ownable {
    using Strings for uint256;

    mapping(uint256 => string) awardEditionURIMap;
    mapping(uint256 => uint256) awardEditionEntryMap;

    string private baseURISuffix;
    
    constructor(string memory _suffix) ERC1155("") {
        baseURISuffix = _suffix;
    }

    /*
     * Admin functions to adjust, distribute or remove "Soulbound Tokens".
     */

    function airDropAward(uint256 id, address holder) external onlyOwner {
        _mint(holder, id, 1, "");
    }

    function adminBurnAward(address holder, uint256 id) external onlyOwner {
        _burn(holder, id, 1);
    }

    function setSuffix(string calldata _suffix) external onlyOwner {
        baseURISuffix = _suffix;
    }

    function mapAwardEditionURI(uint256 _edition, string calldata _awardEditionURI) external onlyOwner {
        awardEditionURIMap[_edition] = _awardEditionURI;
    }

    function mapAwardID(uint256 _startingId, uint256 _quantity, uint256 _editionID) external onlyOwner {
        for (uint i = 0; i < _quantity; i++){
            awardEditionEntryMap[_startingId + i] = _editionID;
        }
    }

    /*
     * Holder function to burn owned "Soulbound Token".
     */

    function burnAward(uint256 id) external {
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 id) public view override returns (string memory) {
        string memory editionBaseURI = awardEditionURIMap[awardEditionEntryMap[id]];
        return string(abi.encodePacked(editionBaseURI, id.toString(), baseURISuffix));
    }
    
    /*
     * Functions for NFT transfers and approvals have been overridden.
     * If user still tries to call these functions we revert and safe them some gas.
     */
    
    function setApprovalForAll(
        address,
        bool
    ) public pure override {
        revert FunctionNotSupported();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure override {
        revert FunctionNotSupported();
    }

    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure override {
        revert FunctionNotSupported();
    }
}