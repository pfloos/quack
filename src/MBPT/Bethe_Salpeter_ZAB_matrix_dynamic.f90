subroutine Bethe_Salpeter_ZAB_matrix_dynamic(eta,nBas,nC,nO,nV,nR,nS,lambda,eGW,OmRPA,rho_RPA,OmBSE, & 
                                             ZAp,ZAm,ZBp,ZBm)

! Compute the dynamic part of the renormalization for the Bethe-Salpeter equation matrices

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: nBas,nC,nO,nV,nR,nS
  double precision,intent(in)   :: eta
  double precision,intent(in)   :: lambda
  double precision,intent(in)   :: eGW(nBas)
  double precision,intent(in)   :: OmRPA(nS)
  double precision,intent(in)   :: rho_RPA(nBas,nBas,nS)
  double precision,intent(in)   :: OmBSE
  
! Local variables

  integer                       :: maxS
  double precision              :: chi_Ap,chi_Bp,eps_Ap,eps_Bp
  double precision              :: chi_Am,chi_Bm,eps_Am,eps_Bm
  integer                       :: i,j,a,b,ia,jb,kc

! Output variables

  double precision,intent(out)  :: ZAp(nS,nS)
  double precision,intent(out)  :: ZAm(nS,nS)

  double precision,intent(out)  :: ZBp(nS,nS)
  double precision,intent(out)  :: ZBm(nS,nS)

! Initialization

  ZAp(:,:) = 0d0
  ZAm(:,:) = 0d0

  ZBp(:,:) = 0d0
  ZBm(:,:) = 0d0

! Number of poles taken into account 

  maxS = nS

! Build dynamic A matrix

  ia = 0
  do i=nC+1,nO
    do a=nO+1,nBas-nR
      ia = ia + 1
      jb = 0
      do j=nC+1,nO
        do b=nO+1,nBas-nR
          jb = jb + 1
 
          chi_Ap = 0d0
          chi_Am = 0d0

          chi_Bp = 0d0
          chi_Bm = 0d0

          do kc=1,maxS

            eps_Ap = + OmBSE - OmRPA(kc) - (eGW(a) - eGW(j))
            chi_Ap = chi_Ap + rho_RPA(i,j,kc)*rho_RPA(a,b,kc)*(eps_Ap**2 - eta**2)/(eps_Ap**2 + eta**2)**2

            eps_Ap = + OmBSE - OmRPA(kc) - (eGW(b) - eGW(i))
            chi_Ap = chi_Ap + rho_RPA(i,j,kc)*rho_RPA(a,b,kc)*(eps_Ap**2 - eta**2)/(eps_Ap**2 + eta**2)**2

            eps_Am = - OmBSE - OmRPA(kc) - (eGW(a) - eGW(j))
            chi_Am = chi_Am + rho_RPA(i,j,kc)*rho_RPA(a,b,kc)*(eps_Am**2 - eta**2)/(eps_Am**2 + eta**2)**2

            eps_Am = - OmBSE - OmRPA(kc) - (eGW(b) - eGW(i))
            chi_Am = chi_Am + rho_RPA(i,j,kc)*rho_RPA(a,b,kc)*(eps_Am**2 - eta**2)/(eps_Am**2 + eta**2)**2

            eps_Bp = + OmBSE - OmRPA(kc) - (eGW(a) - eGW(b))
            chi_Bp = chi_Bp + rho_RPA(i,b,kc)*rho_RPA(a,j,kc)*(eps_Bp**2 - eta**2)/(eps_Bp**2 + eta**2)**2

            eps_Bp = + OmBSE - OmRPA(kc) - (eGW(j) - eGW(i))
            chi_Bp = chi_Bp + rho_RPA(i,b,kc)*rho_RPA(a,j,kc)*(eps_Bp**2 - eta**2)/(eps_Bp**2 + eta**2)**2

            eps_Bm = - OmBSE - OmRPA(kc) - (eGW(a) - eGW(b))
            chi_Bm = chi_Bm + rho_RPA(i,b,kc)*rho_RPA(a,j,kc)*(eps_Bm**2 - eta**2)/(eps_Bm**2 + eta**2)**2

            eps_Bm = - OmBSE - OmRPA(kc) - (eGW(j) - eGW(i))
            chi_Bm = chi_Bm + rho_RPA(i,b,kc)*rho_RPA(a,j,kc)*(eps_Bm**2 - eta**2)/(eps_Bm**2 + eta**2)**2

          enddo

          ZAp(ia,jb) = ZAp(ia,jb) + 2d0*lambda*chi_Ap
          ZAm(ia,jb) = ZAm(ia,jb) - 2d0*lambda*chi_Am

          ZBp(ia,jb) = ZBp(ia,jb) + 2d0*lambda*chi_Bp
          ZBm(ia,jb) = ZBm(ia,jb) - 2d0*lambda*chi_Bm

        enddo
      enddo
    enddo
  enddo

end subroutine Bethe_Salpeter_ZAB_matrix_dynamic
